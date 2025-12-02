"""
Story Analyzer Service (Version 2.3)

Uses Gemini to analyze user's story text and extract:
- Central stressor as GENERAL CATEGORY (e.g., "Public Performance Anxiety")
- Psychological factors with DEEP INSIGHTS (root causes, cognitive biases, sociological context)
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
    """Analyzes story text using Gemini to extract psychological factors with deep insights."""

    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel(settings.GEMINI_MODEL)

    async def analyze_story(
        self,
        story_text: str,
        selected_emotions: List[str]
    ) -> Dict[str, Any]:
        """
        Analyze the user's story text to extract psychological factors with deep insights.

        Args:
            story_text: The user's story text (min 50 chars)
            selected_emotions: List of emotion IDs the user selected

        Returns:
            Dict with:
            - central_stressor: General category (e.g., "Public Performance Anxiety")
            - factors: List of psychological factors with name and insight
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
        """Build the prompt for Gemini to provide deep psychological analysis."""

        emotion_names = [e.replace("_", " ") for e in selected_emotions]
        emotions_str = ", ".join(emotion_names)

        prompt = f"""You are a psychologist helping someone understand the deeper reasons behind their feelings. They feel: {emotions_str}

Their story:
"{story_text}"

Your task is to provide DEEP PSYCHOLOGICAL INSIGHTS (not surface-level descriptions):

1. Identify the DOMINANT LANGUAGE of the text (ISO 639-1 code: "en", "zh", "es", etc.)

2. Identify the CENTRAL STRESSOR as a GENERAL CATEGORY (not the specific event)
   - Good: "Public Performance Anxiety", "Workplace Conflict", "Achievement Pressure"
   - Bad: "Company Annual Gala", "Manager criticized presentation" (too specific)

3. Identify 3-5 PSYCHOLOGICAL FACTORS with DEEP INSIGHTS for each:
   - Factor name: 2-4 words, Title Case (e.g., "Fear of Judgment")
   - Insight MUST include:
     * Psychological root cause (e.g., evolutionary need for acceptance)
     * Cognitive bias explanation WITHOUT naming the bias (e.g., "We tend to overestimate how much others notice our mistakes" instead of "Spotlight Effect")
     * Light sociological context when relevant (e.g., workplace hierarchies)
   - Keep insights brief but meaningful (1-3 sentences)

EXAMPLE of surface vs deep insight:
- Surface (DON'T): "Fear of Judgment - Afraid of being mocked by colleagues"
- Deep (DO): "Fear of Judgment - We tend to overestimate how much others scrutinize us; colleagues are likely focused on their own concerns. Workplace hierarchies can amplify this feeling."

IMPORTANT:
- Return ALL text in the SAME LANGUAGE as the input text
- Factor names should be Title Case (e.g., "Social Anxiety" not "social anxiety")
- Do NOT include reframing advice or suggestions - just insights

Return your response as valid JSON:
{{
  "language": "en",
  "central_stressor": "General Category Name",
  "factors": [
    {{
      "factor": "Factor Name",
      "insight": "Deep psychological insight with root cause, cognitive bias explanation (without naming), and sociological context."
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
                            "insight": factor.get("insight", "")
                        })
                result["factors"] = validated_factors[:5]  # Max 5 factors (3-5 expected)

                return result

        except json.JSONDecodeError as e:
            logger.warning(f"Failed to parse Gemini response as JSON: {e}")

        # If parsing fails, return a basic fallback
        return {
            "language": "en",
            "central_stressor": "Personal Situation",
            "factors": [
                {"factor": "Emotional Response", "insight": "Our feelings often reflect deeper needs and concerns that deserve attention."}
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

        # Create emotion-based factors with deep psychological insights
        emotion_to_factor = {
            "super_happy": ("Positive Achievement", "Our brains are wired to seek accomplishment; this feeling reflects successful goal pursuit and social validation."),
            "pumped": ("Excitement", "Heightened arousal prepares us for action; we often feel most alive when anticipating positive outcomes."),
            "cozy": ("Comfort", "The need for safety is fundamental; feeling secure allows our nervous system to relax and restore."),
            "chill": ("Relaxation", "A calm state signals that immediate threats are absent, allowing mental resources to be redirected toward reflection."),
            "content": ("Satisfaction", "Contentment arises when our current reality aligns with our expectations; we feel 'enough' in this moment."),
            "fuming": ("Frustration", "Anger often masks underlying feelings of powerlessness; it signals that something important to us feels threatened."),
            "freaked_out": ("Anxiety", "We tend to overestimate threats and underestimate our ability to cope; uncertainty triggers protective vigilance."),
            "mad_as_hell": ("Intense Anger", "Strong anger often indicates a perceived violation of fairness or boundaries that matter deeply to us."),
            "blah": ("Apathy", "Lack of motivation can signal emotional exhaustion or disconnection from activities that once held meaning."),
            "down": ("Sadness", "Sadness often reflects loss or unmet expectations; it invites us to slow down and process what matters."),
            "bored_stiff": ("Monotony", "Boredom signals a gap between our need for stimulation and our current environment; it can prompt growth-seeking."),
        }

        # Chinese translations with deep insights
        emotion_to_factor_zh = {
            "super_happy": ("积极成就", "我们的大脑天生追求成就感；这种感觉反映了成功的目标追求和社会认可。"),
            "pumped": ("兴奋", "高度的兴奋让我们准备好行动；当我们期待积极的结果时，往往感觉最有活力。"),
            "cozy": ("舒适", "对安全感的需求是人类的基本需求；感到安全让我们的神经系统得以放松和恢复。"),
            "chill": ("放松", "平静的状态表明眼前没有威胁，让心理资源可以转向反思。"),
            "content": ("满足", "当现实与期望一致时，满足感就会产生；我们在这一刻感到'足够'。"),
            "fuming": ("挫折感", "愤怒往往掩盖了潜在的无力感；它表明对我们重要的东西感到受威胁。"),
            "freaked_out": ("焦虑", "我们往往会高估威胁，低估自己的应对能力；不确定性会触发保护性警觉。"),
            "mad_as_hell": ("强烈愤怒", "强烈的愤怒通常表明我们认为公平或重要的界限被侵犯了。"),
            "blah": ("冷漠", "缺乏动力可能表明情感疲惫或与曾经有意义的活动脱节。"),
            "down": ("悲伤", "悲伤往往反映失去或未满足的期望；它邀请我们放慢脚步，处理重要的事情。"),
            "bored_stiff": ("单调", "无聊表明我们对刺激的需求与当前环境之间存在差距；它可以促使我们寻求成长。"),
        }

        factor_map = emotion_to_factor_zh if language == "zh" else emotion_to_factor

        factors = []
        for emotion in selected_emotions[:4]:  # Max 4 factors from emotions
            if emotion in factor_map:
                name, insight_text = factor_map[emotion]
                factors.append({"factor": name, "insight": insight_text})

        central = "当前情况" if language == "zh" else "Current Situation"

        return {
            "language": language,
            "central_stressor": central,
            "factors": factors if factors else [
                {"factor": "情绪反应" if language == "zh" else "Emotional Response",
                 "insight": "我们的感受往往反映了更深层的需求和关注点，值得我们关注。" if language == "zh" else "Our feelings often reflect deeper needs and concerns that deserve attention."}
            ]
        }


# Global instance
story_analyzer = StoryAnalyzer()
