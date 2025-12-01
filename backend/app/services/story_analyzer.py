"""
Story Analyzer Service (Version 2.1)

Uses Gemini to analyze user's story text and extract:
- Central stressor (main situation/issue)
- Emotional factors contributing to feelings
- Detected dominant language
"""

import google.generativeai as genai
from app.core.config import settings
from typing import List, Dict, Any
import json
import logging
import re

logger = logging.getLogger(__name__)


class StoryAnalyzer:
    """Analyzes story text using Gemini to extract emotional factors."""

    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel(settings.GEMINI_MODEL)

    async def analyze_story(
        self,
        story_text: str,
        selected_emotions: List[str]
    ) -> Dict[str, Any]:
        """
        Analyze the user's story text to extract stressors and emotional factors.

        Args:
            story_text: The user's story text (min 50 chars)
            selected_emotions: List of emotion IDs the user selected

        Returns:
            Dict with:
            - central_stressor: Main situation identified
            - factors: List of emotional factors with name and description
            - language: Detected dominant language code (e.g., "en", "zh")
        """
        try:
            # Build the analysis prompt
            prompt = self._build_analysis_prompt(story_text, selected_emotions)

            # Call Gemini
            response = self.model.generate_content(prompt)

            # Parse the response
            result = self._parse_response(response.text)

            logger.info(f"Story analysis complete: language={result.get('language')}, "
                       f"factors_count={len(result.get('factors', []))}")

            return result

        except Exception as e:
            logger.error(f"Story analysis failed: {e}")
            # Return fallback analysis
            return self._generate_fallback_analysis(story_text, selected_emotions)

    def _build_analysis_prompt(
        self,
        story_text: str,
        selected_emotions: List[str]
    ) -> str:
        """Build the prompt for Gemini to analyze the story."""

        emotion_names = [e.replace("_", " ") for e in selected_emotions]
        emotions_str = ", ".join(emotion_names)

        prompt = f"""Analyze this text where someone is describing their feelings. They have indicated they feel: {emotions_str}

Their story:
"{story_text}"

Your task:
1. Identify the DOMINANT LANGUAGE of the text (use ISO 639-1 code, e.g., "en" for English, "zh" for Chinese, "es" for Spanish)
2. Identify the CENTRAL STRESSOR - the main situation or issue causing these feelings
3. Identify 2-4 EMOTIONAL FACTORS - the underlying reasons contributing to their emotional state

IMPORTANT:
- Return ALL text labels (central_stressor, factor names, and descriptions) in the SAME LANGUAGE as the dominant language of the input text
- If the input is in Chinese, respond with Chinese labels
- If the input is in English, respond with English labels
- For mixed language input, use the language that appears most frequently

Return your response as valid JSON in exactly this format:
{{
  "language": "en",
  "central_stressor": "The main situation or issue",
  "factors": [
    {{
      "factor": "Factor Name",
      "description": "Brief description of how this factor relates to the story"
    }},
    {{
      "factor": "Another Factor",
      "description": "Brief description"
    }}
  ]
}}

Return ONLY the JSON, no other text."""

        return prompt

    def _parse_response(self, response_text: str) -> Dict[str, Any]:
        """Parse Gemini's response to extract the analysis."""
        try:
            # Try to extract JSON from the response
            # Sometimes Gemini wraps it in markdown code blocks
            json_match = re.search(r'\{[\s\S]*\}', response_text)
            if json_match:
                json_str = json_match.group()
                result = json.loads(json_str)

                # Validate required fields
                if "central_stressor" not in result:
                    result["central_stressor"] = "Unidentified situation"
                if "factors" not in result:
                    result["factors"] = []
                if "language" not in result:
                    result["language"] = "en"

                # Ensure factors have required fields
                validated_factors = []
                for factor in result.get("factors", []):
                    if isinstance(factor, dict) and "factor" in factor:
                        validated_factors.append({
                            "factor": factor.get("factor", ""),
                            "description": factor.get("description", "")
                        })
                result["factors"] = validated_factors[:4]  # Max 4 factors

                return result

        except json.JSONDecodeError as e:
            logger.warning(f"Failed to parse Gemini response as JSON: {e}")

        # If parsing fails, return a basic fallback
        return {
            "language": "en",
            "central_stressor": "Personal situation",
            "factors": [
                {"factor": "Emotional response", "description": "Feelings about the situation"}
            ]
        }

    def _generate_fallback_analysis(
        self,
        story_text: str,
        selected_emotions: List[str]
    ) -> Dict[str, Any]:
        """Generate a fallback analysis when Gemini call fails."""

        # Detect language simply by checking for Chinese characters
        has_chinese = bool(re.search(r'[\u4e00-\u9fff]', story_text))
        language = "zh" if has_chinese else "en"

        # Create emotion-based factors
        emotion_to_factor = {
            "super_happy": ("Positive Achievement", "Sense of accomplishment or joy"),
            "pumped": ("Excitement", "Energized feelings about the situation"),
            "cozy": ("Comfort", "Feeling of safety and warmth"),
            "chill": ("Relaxation", "Calm and peaceful state"),
            "content": ("Satisfaction", "Feeling fulfilled and at peace"),
            "fuming": ("Frustration", "Anger about the situation"),
            "freaked_out": ("Anxiety", "Worry and uncertainty"),
            "mad_as_hell": ("Intense Anger", "Strong negative reaction"),
            "blah": ("Apathy", "Lack of motivation or interest"),
            "down": ("Sadness", "Low mood and disappointment"),
            "bored_stiff": ("Monotony", "Lack of stimulation"),
        }

        # Chinese translations
        emotion_to_factor_zh = {
            "super_happy": ("积极成就", "成就感或喜悦"),
            "pumped": ("兴奋", "对情况充满活力的感觉"),
            "cozy": ("舒适", "安全和温暖的感觉"),
            "chill": ("放松", "平静和平和的状态"),
            "content": ("满足", "感到充实和平静"),
            "fuming": ("挫折感", "对情况的愤怒"),
            "freaked_out": ("焦虑", "担忧和不确定"),
            "mad_as_hell": ("强烈愤怒", "强烈的负面反应"),
            "blah": ("冷漠", "缺乏动力或兴趣"),
            "down": ("悲伤", "低落的情绪和失望"),
            "bored_stiff": ("单调", "缺乏刺激"),
        }

        factor_map = emotion_to_factor_zh if language == "zh" else emotion_to_factor

        factors = []
        for emotion in selected_emotions[:3]:  # Max 3 factors from emotions
            if emotion in factor_map:
                name, desc = factor_map[emotion]
                factors.append({"factor": name, "description": desc})

        central = "当前情况" if language == "zh" else "Current situation"

        return {
            "language": language,
            "central_stressor": central,
            "factors": factors if factors else [
                {"factor": "情绪反应" if language == "zh" else "Emotional response",
                 "description": "对情况的感受" if language == "zh" else "Feelings about the situation"}
            ]
        }


# Global instance
story_analyzer = StoryAnalyzer()
