import google.generativeai as genai
from google.generativeai import types
from app.core.config import settings
from typing import List, Dict, Any, Optional
import base64
import io
import asyncio
import time
import logging
from PIL import Image

logger = logging.getLogger(__name__)


class GeminiAPIError(Exception):
    """Custom exception for Gemini API errors."""
    pass


class GeminiClient:
    """Client for interacting with Google Gemini API"""

    def __init__(self):
        genai.configure(api_key=settings.GEMINI_API_KEY)
        self.model = genai.GenerativeModel(settings.GEMINI_MODEL)
        self.imagen_model = None  # Lazy initialization for Imagen
        self.timeout = settings.GEMINI_TIMEOUT_SECONDS
        self.max_retries = settings.GEMINI_MAX_RETRIES
        self.image_size = settings.VISUALIZATION_IMAGE_SIZE

    def _get_imagen_model(self):
        """Lazy initialization of Imagen model."""
        if self.imagen_model is None:
            try:
                # Try to get ImageGenerationModel if available
                if hasattr(genai, 'ImageGenerationModel'):
                    self.imagen_model = genai.ImageGenerationModel("imagen-3.0-generate-002")
                else:
                    logger.info("ImageGenerationModel not available in this SDK version")
            except Exception as e:
                logger.warning(f"Failed to initialize Imagen model: {e}")
        return self.imagen_model

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

    async def generate_visualization_image(self, prompt: str) -> Dict[str, Any]:
        """
        Generate a mood visualization image using Gemini Imagen.

        Args:
            prompt: The image generation prompt

        Returns:
            dict with image_data (base64), width, height, generation_time_ms

        Raises:
            GeminiAPIError: If API call fails
        """
        start_time = time.time()
        last_exception = None

        for attempt in range(self.max_retries + 1):
            try:
                logger.info(f"Generating image, attempt {attempt + 1}")

                # Generate image using Imagen
                response = await asyncio.wait_for(
                    asyncio.to_thread(
                        self._generate_image_sync,
                        prompt
                    ),
                    timeout=self.timeout
                )

                generation_time_ms = int((time.time() - start_time) * 1000)

                return {
                    "image_data": response["base64"],
                    "width": response["width"],
                    "height": response["height"],
                    "generation_time_ms": generation_time_ms
                }

            except asyncio.TimeoutError:
                logger.warning(f"Image generation timeout, attempt {attempt + 1}")
                last_exception = GeminiAPIError("Image generation timed out")

            except Exception as e:
                logger.error(f"Image generation error: {str(e)}")
                last_exception = GeminiAPIError(f"Image generation failed: {str(e)}")

                # Don't retry on certain errors
                error_str = str(e).lower()
                if "safety" in error_str or "blocked" in error_str:
                    raise GeminiAPIError("Content was filtered by safety settings")
                if "invalid" in error_str and "api key" in error_str:
                    raise GeminiAPIError("Invalid API key configuration")

            # Wait before retry
            if attempt < self.max_retries:
                await asyncio.sleep(1 * (2 ** attempt))

        raise last_exception or GeminiAPIError("Image generation failed after retries")

    def _generate_image_sync(self, prompt: str) -> Dict[str, Any]:
        """
        Synchronous image generation (called in thread).

        Note: This uses Imagen API. If Imagen is not available,
        falls back to generating a placeholder image.
        """
        imagen = self._get_imagen_model()

        if imagen is None:
            logger.info("Imagen not available, using placeholder image")
            return self._generate_placeholder_image(prompt)

        try:
            # Try Imagen API
            response = imagen.generate_images(
                prompt=prompt,
                number_of_images=1,
                aspect_ratio="1:1",
                safety_filter_level="block_some",
                person_generation="dont_allow"
            )

            # Get the generated image
            generated_image = response.images[0]

            # Convert to PIL Image and then to base64
            pil_image = generated_image._pil_image
            return self._process_image(pil_image)

        except Exception as e:
            logger.warning(f"Imagen API failed: {e}, using fallback placeholder")
            # Fallback: Generate a placeholder gradient image
            return self._generate_placeholder_image(prompt)

    def _process_image(self, pil_image: Image.Image) -> Dict[str, Any]:
        """Process PIL image to standard format."""
        # Resize if needed
        if pil_image.size != (self.image_size, self.image_size):
            pil_image = pil_image.resize(
                (self.image_size, self.image_size),
                Image.LANCZOS
            )

        # Convert to RGB if necessary
        if pil_image.mode != 'RGB':
            pil_image = pil_image.convert('RGB')

        # Convert to base64
        buffer = io.BytesIO()
        pil_image.save(buffer, format='PNG', optimize=True)
        image_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')

        return {
            "base64": image_base64,
            "width": self.image_size,
            "height": self.image_size
        }

    def _generate_placeholder_image(self, prompt: str) -> Dict[str, Any]:
        """
        Generate a placeholder image for development/fallback.

        Creates different styles based on prompt type:
        - Abstract art for feeling visualizations (gradients with shapes)
        - 2D cartoon style for story visualizations (scene with characters)
        """
        prompt_lower = prompt.lower()

        # Check if this is a story visualization (2D cartoon) or feeling visualization (abstract)
        is_story = "2d cartoon" in prompt_lower or "story to illustrate" in prompt_lower or "cartoon illustration" in prompt_lower

        if is_story:
            return self._generate_cartoon_placeholder(prompt_lower)
        else:
            return self._generate_abstract_placeholder(prompt_lower)

    def _generate_abstract_placeholder(self, prompt_lower: str) -> Dict[str, Any]:
        """Generate abstract art placeholder with gradients and shapes."""
        from PIL import ImageDraw
        import math

        # Determine colors based on prompt
        if any(word in prompt_lower for word in ["happy", "joy", "bright", "warm"]):
            color1 = (255, 245, 220)  # Warm cream
            color2 = (255, 218, 185)  # Peach
            accent = (255, 200, 150)  # Orange accent
        elif any(word in prompt_lower for word in ["calm", "chill", "peaceful", "relaxed"]):
            color1 = (230, 245, 255)  # Light blue
            color2 = (200, 230, 220)  # Soft mint
            accent = (180, 220, 200)  # Mint accent
        elif any(word in prompt_lower for word in ["sad", "down", "low"]):
            color1 = (220, 225, 235)  # Cool gray-blue
            color2 = (200, 210, 225)  # Pale indigo
            accent = (180, 190, 210)  # Blue accent
        elif any(word in prompt_lower for word in ["angry", "fuming", "intense"]):
            color1 = (245, 225, 225)  # Soft pink
            color2 = (235, 215, 215)  # Muted coral
            accent = (220, 180, 180)  # Red accent
        else:
            color1 = (240, 245, 250)  # Neutral light
            color2 = (225, 235, 245)  # Soft blue-gray
            accent = (210, 220, 235)  # Blue accent

        # Create gradient image
        image = Image.new('RGB', (self.image_size, self.image_size))
        pixels = image.load()

        for y in range(self.image_size):
            for x in range(self.image_size):
                # Diagonal gradient
                ratio = (x + y) / (2 * self.image_size)
                r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
                g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
                b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
                pixels[x, y] = (r, g, b)

        # Add abstract shapes (circles) for more visual interest
        draw = ImageDraw.Draw(image)
        center = self.image_size // 2

        # Draw some soft circles
        for i in range(3):
            radius = self.image_size // (3 + i)
            offset = i * 30
            # Draw with transparency effect by using lighter colors
            circle_color = tuple(min(255, c + 20) for c in accent)
            draw.ellipse(
                [center - radius + offset, center - radius - offset,
                 center + radius + offset, center + radius - offset],
                outline=circle_color,
                width=3
            )

        return self._process_image(image)

    def _generate_cartoon_placeholder(self, prompt_lower: str) -> Dict[str, Any]:
        """Generate 2D cartoon-style placeholder with simple scene."""
        from PIL import ImageDraw

        # Determine scene mood based on emotions in prompt
        if any(word in prompt_lower for word in ["happy", "joy", "pumped", "super happy"]):
            sky_color = (255, 250, 220)  # Sunny yellow
            ground_color = (180, 230, 180)  # Green grass
            accent_color = (255, 200, 100)  # Sun yellow
            mood = "happy"
        elif any(word in prompt_lower for word in ["calm", "chill", "peaceful", "content", "cozy"]):
            sky_color = (230, 245, 255)  # Calm blue sky
            ground_color = (200, 220, 180)  # Soft green
            accent_color = (255, 255, 200)  # Soft sun
            mood = "calm"
        elif any(word in prompt_lower for word in ["sad", "down", "blah"]):
            sky_color = (210, 215, 225)  # Overcast
            ground_color = (180, 190, 170)  # Muted green
            accent_color = (190, 195, 205)  # Cloud gray
            mood = "sad"
        elif any(word in prompt_lower for word in ["angry", "fuming", "mad", "freaked"]):
            sky_color = (240, 225, 225)  # Pinkish sky
            ground_color = (190, 180, 170)  # Dusty ground
            accent_color = (220, 180, 180)  # Warm accent
            mood = "intense"
        else:
            sky_color = (235, 245, 255)  # Neutral sky
            ground_color = (190, 210, 180)  # Neutral grass
            accent_color = (255, 240, 200)  # Neutral sun
            mood = "neutral"

        # Create base image
        image = Image.new('RGB', (self.image_size, self.image_size), sky_color)
        draw = ImageDraw.Draw(image)

        # Draw ground (lower third)
        ground_y = int(self.image_size * 0.7)
        draw.rectangle([0, ground_y, self.image_size, self.image_size], fill=ground_color)

        # Draw sun or cloud based on mood
        if mood in ["happy", "calm", "neutral"]:
            # Draw sun
            sun_x = int(self.image_size * 0.8)
            sun_y = int(self.image_size * 0.15)
            sun_radius = int(self.image_size * 0.08)
            draw.ellipse(
                [sun_x - sun_radius, sun_y - sun_radius,
                 sun_x + sun_radius, sun_y + sun_radius],
                fill=accent_color
            )
        else:
            # Draw clouds
            cloud_y = int(self.image_size * 0.15)
            for cloud_x in [int(self.image_size * 0.3), int(self.image_size * 0.7)]:
                for dx, dy, r in [(0, 0, 25), (-20, 5, 20), (20, 5, 20), (0, -10, 18)]:
                    draw.ellipse(
                        [cloud_x + dx - r, cloud_y + dy - r,
                         cloud_x + dx + r, cloud_y + dy + r],
                        fill=accent_color
                    )

        # Draw simple stick figure character
        char_x = int(self.image_size * 0.5)
        char_y = int(self.image_size * 0.55)

        # Character color
        char_color = (100, 100, 100)  # Gray for stick figure
        head_color = (255, 220, 180)  # Skin tone

        # Head
        head_radius = int(self.image_size * 0.05)
        draw.ellipse(
            [char_x - head_radius, char_y - head_radius,
             char_x + head_radius, char_y + head_radius],
            fill=head_color,
            outline=char_color,
            width=2
        )

        # Simple face based on mood
        eye_y = char_y - int(head_radius * 0.2)
        eye_offset = int(head_radius * 0.4)
        eye_size = 3

        # Eyes
        draw.ellipse([char_x - eye_offset - eye_size, eye_y - eye_size,
                      char_x - eye_offset + eye_size, eye_y + eye_size], fill=char_color)
        draw.ellipse([char_x + eye_offset - eye_size, eye_y - eye_size,
                      char_x + eye_offset + eye_size, eye_y + eye_size], fill=char_color)

        # Mouth based on mood
        mouth_y = char_y + int(head_radius * 0.4)
        mouth_width = int(head_radius * 0.6)
        if mood == "happy":
            # Smile
            draw.arc([char_x - mouth_width, mouth_y - mouth_width//2,
                      char_x + mouth_width, mouth_y + mouth_width//2],
                     0, 180, fill=char_color, width=2)
        elif mood in ["sad", "down"]:
            # Frown
            draw.arc([char_x - mouth_width, mouth_y,
                      char_x + mouth_width, mouth_y + mouth_width],
                     180, 360, fill=char_color, width=2)
        else:
            # Neutral line
            draw.line([char_x - mouth_width//2, mouth_y,
                       char_x + mouth_width//2, mouth_y], fill=char_color, width=2)

        # Body
        body_top = char_y + head_radius
        body_bottom = int(self.image_size * 0.68)
        draw.line([char_x, body_top, char_x, body_bottom], fill=char_color, width=3)

        # Arms
        arm_y = body_top + int((body_bottom - body_top) * 0.3)
        arm_length = int(self.image_size * 0.06)
        if mood == "happy":
            # Arms up
            draw.line([char_x, arm_y, char_x - arm_length, arm_y - arm_length//2], fill=char_color, width=3)
            draw.line([char_x, arm_y, char_x + arm_length, arm_y - arm_length//2], fill=char_color, width=3)
        else:
            # Arms down
            draw.line([char_x, arm_y, char_x - arm_length, arm_y + arm_length//2], fill=char_color, width=3)
            draw.line([char_x, arm_y, char_x + arm_length, arm_y + arm_length//2], fill=char_color, width=3)

        # Legs
        leg_length = int(self.image_size * 0.05)
        draw.line([char_x, body_bottom, char_x - leg_length//2, ground_y - 5], fill=char_color, width=3)
        draw.line([char_x, body_bottom, char_x + leg_length//2, ground_y - 5], fill=char_color, width=3)

        # Add some simple scenery elements
        # Tree on the left
        tree_x = int(self.image_size * 0.15)
        trunk_width = 8
        trunk_height = int(self.image_size * 0.12)
        trunk_bottom = ground_y
        trunk_top = trunk_bottom - trunk_height

        # Trunk
        draw.rectangle([tree_x - trunk_width//2, trunk_top,
                        tree_x + trunk_width//2, trunk_bottom],
                       fill=(139, 90, 43))

        # Leaves (simple circle)
        leaves_radius = int(self.image_size * 0.07)
        leaves_color = (100, 180, 100) if mood != "sad" else (120, 150, 120)
        draw.ellipse([tree_x - leaves_radius, trunk_top - leaves_radius,
                      tree_x + leaves_radius, trunk_top + leaves_radius//2],
                     fill=leaves_color)

        return self._process_image(image)

    async def check_visualization_health(self) -> Dict[str, Any]:
        """Check if visualization service (Gemini/Imagen) is accessible."""
        try:
            start_time = time.time()
            # Simple API connectivity check
            response = self.model.generate_content("Hello")
            latency_ms = int((time.time() - start_time) * 1000)

            return {
                "status": "healthy",
                "latency_ms": latency_ms
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e)
            }


# Global instance
gemini_client = GeminiClient()
