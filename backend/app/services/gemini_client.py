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
        - Mind-map diagram for story visualizations (with labels and icons)
        """
        prompt_lower = prompt.lower()

        # Check if this is a story visualization (mind-map diagram) or feeling visualization (abstract)
        is_story = "mind-map" in prompt_lower or "diagram" in prompt_lower or "central situation" in prompt_lower

        if is_story:
            return self._generate_mindmap_placeholder(prompt)
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

    def _generate_mindmap_placeholder(self, prompt: str) -> Dict[str, Any]:
        """Generate mind-map diagram with fixed 4-corner layout (v2.4)."""
        from PIL import ImageDraw, ImageFont
        import re

        # Parse the prompt to extract central stressor and factors
        central_stressor = "Main Issue"
        factors = []

        # Extract central stressor
        central_match = re.search(r'label "([^"]+)" below it', prompt)
        if central_match:
            central_stressor = central_match.group(1)

        # Extract factors
        factor_matches = re.findall(r'Icon \+ label: "([^"]+)"', prompt)
        if factor_matches:
            factors = factor_matches[:4]  # Max 4 factors for 4-corner layout

        # If no factors found, use defaults
        if not factors:
            factors = ["Factor 1", "Factor 2", "Factor 3", "Factor 4"]

        # Pad to 4 factors if needed
        while len(factors) < 4:
            factors.append("")

        # Colors
        bg_color = (250, 252, 255)  # Very light blue-white
        center_color = (135, 206, 235)  # Sky blue
        factor_colors = [
            (255, 182, 193),  # Light pink - top-left
            (176, 224, 230),  # Powder blue - top-right
            (255, 218, 185),  # Peach - bottom-left
            (221, 160, 221),  # Plum - bottom-right
        ]
        line_color = (180, 180, 190)  # Light gray
        text_color = (60, 60, 70)  # Dark gray

        # Create image
        image = Image.new('RGB', (self.image_size, self.image_size), bg_color)
        draw = ImageDraw.Draw(image)

        center_x = self.image_size // 2
        center_y = self.image_size // 2

        # Icon sizes
        center_radius = int(self.image_size * 0.10)
        factor_radius = int(self.image_size * 0.065)

        # Fixed 4-corner positions (as per v2.4 spec)
        # Zone 1 (top-left): x: 0-40%, y: 0-40% -> center at 20%, 20%
        # Zone 2 (top-right): x: 60-100%, y: 0-40% -> center at 80%, 20%
        # Zone 3 (bottom-left): x: 0-40%, y: 60-100% -> center at 20%, 80%
        # Zone 4 (bottom-right): x: 60-100%, y: 60-100% -> center at 80%, 80%
        corner_positions = [
            (int(self.image_size * 0.22), int(self.image_size * 0.22)),  # top-left
            (int(self.image_size * 0.78), int(self.image_size * 0.22)),  # top-right
            (int(self.image_size * 0.22), int(self.image_size * 0.78)),  # bottom-left
            (int(self.image_size * 0.78), int(self.image_size * 0.78)),  # bottom-right
        ]
        factor_positions = corner_positions[:len(factors)]

        # Draw connecting lines first (so they're behind icons)
        for fx, fy in factor_positions:
            draw.line([center_x, center_y, fx, fy], fill=line_color, width=2)

        # Draw central icon (larger circle)
        draw.ellipse(
            [center_x - center_radius, center_y - center_radius,
             center_x + center_radius, center_y + center_radius],
            fill=center_color,
            outline=(100, 150, 180),
            width=2
        )

        # Draw a simple icon inside center (target/bullseye)
        inner_r1 = center_radius - 15
        inner_r2 = center_radius - 30
        if inner_r1 > 5:
            draw.ellipse(
                [center_x - inner_r1, center_y - inner_r1,
                 center_x + inner_r1, center_y + inner_r1],
                outline=(100, 150, 180),
                width=2
            )
        if inner_r2 > 5:
            draw.ellipse(
                [center_x - inner_r2, center_y - inner_r2,
                 center_x + inner_r2, center_y + inner_r2],
                fill=(100, 150, 180)
            )

        # Draw factor icons
        for i, (fx, fy) in enumerate(factor_positions):
            color = factor_colors[i % len(factor_colors)]
            outline_color = tuple(max(0, c - 40) for c in color)

            # Draw circle
            draw.ellipse(
                [fx - factor_radius, fy - factor_radius,
                 fx + factor_radius, fy + factor_radius],
                fill=color,
                outline=outline_color,
                width=2
            )

            # Draw simple icon inside (different for each)
            icon_size = factor_radius - 10
            if i == 0:  # Warning triangle
                points = [
                    (fx, fy - icon_size),
                    (fx - icon_size, fy + icon_size//2),
                    (fx + icon_size, fy + icon_size//2)
                ]
                draw.polygon(points, outline=outline_color, width=2)
            elif i == 1:  # Circle
                draw.ellipse(
                    [fx - icon_size//2, fy - icon_size//2,
                     fx + icon_size//2, fy + icon_size//2],
                    outline=outline_color,
                    width=2
                )
            elif i == 2:  # Square
                draw.rectangle(
                    [fx - icon_size//2, fy - icon_size//2,
                     fx + icon_size//2, fy + icon_size//2],
                    outline=outline_color,
                    width=2
                )
            elif i == 3:  # Diamond
                points = [
                    (fx, fy - icon_size),
                    (fx + icon_size, fy),
                    (fx, fy + icon_size),
                    (fx - icon_size, fy)
                ]
                draw.polygon(points, outline=outline_color, width=2)
            else:  # Star-like
                draw.line([fx - icon_size, fy, fx + icon_size, fy], fill=outline_color, width=2)
                draw.line([fx, fy - icon_size, fx, fy + icon_size], fill=outline_color, width=2)

        # Try to load a font, fall back to default
        try:
            font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 18)
            font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
        except:
            try:
                font_large = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 18)
                font_small = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 14)
            except:
                font_large = ImageFont.load_default()
                font_small = ImageFont.load_default()

        # Draw central label (below center icon)
        # Wrap text if too long
        max_chars = 25
        if len(central_stressor) > max_chars:
            words = central_stressor.split()
            lines = []
            current_line = ""
            for word in words:
                if len(current_line + " " + word) <= max_chars:
                    current_line = (current_line + " " + word).strip()
                else:
                    if current_line:
                        lines.append(current_line)
                    current_line = word
            if current_line:
                lines.append(current_line)
        else:
            lines = [central_stressor]

        label_y = center_y + center_radius + 10
        for line in lines:
            bbox = draw.textbbox((0, 0), line, font=font_large)
            text_width = bbox[2] - bbox[0]
            draw.text(
                (center_x - text_width // 2, label_y),
                line,
                fill=text_color,
                font=font_large
            )
            label_y += 20

        # Draw factor labels
        for i, (fx, fy) in enumerate(factor_positions):
            if i < len(factors):
                label = factors[i]
                # Wrap if needed
                if len(label) > 18:
                    words = label.split()
                    if len(words) >= 2:
                        mid = len(words) // 2
                        line1 = " ".join(words[:mid])
                        line2 = " ".join(words[mid:])
                        lines = [line1, line2]
                    else:
                        lines = [label[:18], label[18:]] if len(label) > 18 else [label]
                else:
                    lines = [label]

                # Position label below the icon
                label_y = fy + factor_radius + 8
                for line in lines:
                    bbox = draw.textbbox((0, 0), line, font=font_small)
                    text_width = bbox[2] - bbox[0]
                    draw.text(
                        (fx - text_width // 2, label_y),
                        line,
                        fill=text_color,
                        font=font_small
                    )
                    label_y += 16

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
