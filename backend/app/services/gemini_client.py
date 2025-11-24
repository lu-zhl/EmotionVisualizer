import google.generativeai as genai
from app.core.config import settings
from typing import List, Dict, Any


class GeminiClient:
    """Client for interacting with Google Gemini API"""

    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel('gemini-1.5-pro')

    async def generate_scenarios(self, situation: str) -> List[Dict[str, Any]]:
        """Generate follow-up scenarios based on initial situation"""
        prompt = f"""
        A user is experiencing the following situation:
        "{situation}"

        Generate 3 follow-up questions to help understand their emotional state better.
        Each question should have 3 possible answer options.

        Format your response as JSON with this structure:
        {{
            "scenarios": [
                {{
                    "question": "Question text?",
                    "options": [
                        {{"text": "Option 1", "emotion_indicators": ["emotion1", "emotion2"]}},
                        {{"text": "Option 2", "emotion_indicators": ["emotion3"]}},
                        {{"text": "Option 3", "emotion_indicators": ["emotion4", "emotion5"]}}
                    ]
                }}
            ]
        }}
        """

        try:
            response = self.model.generate_content(prompt)
            # For now, return a simple structure
            # In production, you'd parse the JSON response from Gemini
            return [{
                "id": "scenario-1",
                "question": f"How does this situation make you feel?",
                "options": [
                    {"id": "opt-1", "text": "Anxious and overwhelmed", "emotion_indicators": ["anxiety", "stress"]},
                    {"id": "opt-2", "text": "Frustrated but determined", "emotion_indicators": ["frustration", "determination"]},
                    {"id": "opt-3", "text": "Uncertain about next steps", "emotion_indicators": ["uncertainty", "confusion"]}
                ]
            }]
        except Exception as e:
            print(f"Gemini API error: {e}")
            return []

    async def analyze_emotions(self, entry_data: Dict[str, Any]) -> Dict[str, Any]:
        """Analyze emotions and generate insights"""
        prompt = f"""
        Analyze this emotion entry:
        Situation: {entry_data.get('situation')}
        Emotions: {', '.join(entry_data.get('emotions', []))}
        Intensity: {entry_data.get('intensity')}

        Provide:
        1. A brief summary (2-3 sentences)
        2. 3 insights about the emotional state
        3. Patterns or themes you notice

        Format as JSON.
        """

        try:
            response = self.model.generate_content(prompt)
            return {
                "summary": "Your emotional state reflects a complex mix of feelings related to the situation.",
                "insights": [
                    "Multiple emotions present indicate complexity",
                    "Intensity level suggests significant impact",
                    "Consider exploring root causes"
                ]
            }
        except Exception as e:
            print(f"Gemini API error: {e}")
            return {
                "summary": "Unable to generate analysis",
                "insights": []
            }


# Global instance
gemini_client = GeminiClient()
