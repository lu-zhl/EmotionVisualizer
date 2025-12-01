# Gemini API Integration Guide

## Document Information
- **Milestone**: 004-mood-visualization-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-26
- **Version**: 1.0

---

## 1. Overview

This document describes how to integrate Google Gemini API for image generation in the EmotionVisualizer backend.

## 2. Gemini API Setup

### 2.1 Prerequisites

1. Google Cloud account with billing enabled
2. Gemini API access enabled
3. API key generated from Google AI Studio

### 2.2 Environment Configuration

Add the following to your `.env` file:

```bash
# Gemini API Configuration
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-2.0-flash-exp
GEMINI_TIMEOUT_SECONDS=30
GEMINI_MAX_RETRIES=2
```

**Important**: Never commit API keys to version control.

### 2.3 Dependencies

Add to `requirements.txt`:

```
google-generativeai>=0.3.0
Pillow>=10.0.0
```

## 3. Implementation

### 3.1 Gemini Client Module

Create `backend/services/gemini_service.py`:

```python
import google.generativeai as genai
import base64
import os
from typing import Optional
from PIL import Image
import io

class GeminiService:
    """Service for interacting with Google Gemini API."""

    def __init__(self):
        self.api_key = os.getenv("GEMINI_API_KEY")
        self.model_name = os.getenv("GEMINI_MODEL", "gemini-2.0-flash-exp")
        self.timeout = int(os.getenv("GEMINI_TIMEOUT_SECONDS", 30))

        if not self.api_key:
            raise ValueError("GEMINI_API_KEY environment variable is required")

        genai.configure(api_key=self.api_key)
        self.model = genai.GenerativeModel(self.model_name)

    async def generate_image(self, prompt: str) -> dict:
        """
        Generate an image using Gemini API.

        Args:
            prompt: The image generation prompt

        Returns:
            dict with image_data (base64), width, height

        Raises:
            GeminiAPIError: If API call fails
        """
        try:
            # Generate image using Gemini
            response = await self._call_imagen(prompt)

            # Process and return result
            return {
                "image_data": response["base64"],
                "width": response["width"],
                "height": response["height"]
            }

        except Exception as e:
            raise GeminiAPIError(f"Image generation failed: {str(e)}")

    async def _call_imagen(self, prompt: str) -> dict:
        """
        Internal method to call Gemini Imagen API.

        Note: Implementation depends on Gemini API version.
        Update this method based on latest API documentation.
        """
        # Option 1: Using Imagen through Gemini
        # This is a placeholder - actual implementation depends on
        # which Gemini model/endpoint supports image generation

        response = self.model.generate_content(
            prompt,
            generation_config={
                "response_mime_type": "image/png"
            }
        )

        # Extract image data from response
        # Adjust based on actual API response structure
        image_data = response.candidates[0].content.parts[0].inline_data.data
        image_base64 = base64.b64encode(image_data).decode('utf-8')

        # Get image dimensions
        image = Image.open(io.BytesIO(image_data))
        width, height = image.size

        return {
            "base64": image_base64,
            "width": width,
            "height": height
        }

    async def health_check(self) -> dict:
        """Check if Gemini API is accessible."""
        try:
            # Simple API call to verify connectivity
            response = self.model.generate_content("Hello")
            return {
                "status": "healthy",
                "latency_ms": 0  # Add actual latency measurement
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "error": str(e)
            }


class GeminiAPIError(Exception):
    """Custom exception for Gemini API errors."""
    pass
```

### 3.2 Alternative: Using Vertex AI Imagen

If using Vertex AI for image generation:

```python
from google.cloud import aiplatform
from vertexai.preview.vision_models import ImageGenerationModel

class VertexImagenService:
    """Service for image generation using Vertex AI Imagen."""

    def __init__(self):
        self.project_id = os.getenv("GCP_PROJECT_ID")
        self.location = os.getenv("GCP_LOCATION", "us-central1")

        aiplatform.init(project=self.project_id, location=self.location)
        self.model = ImageGenerationModel.from_pretrained("imagen-3.0-generate-001")

    async def generate_image(self, prompt: str) -> dict:
        """Generate image using Vertex AI Imagen."""
        images = self.model.generate_images(
            prompt=prompt,
            number_of_images=1,
            aspect_ratio="1:1",
            safety_filter_level="block_some",
            person_generation="allow_adult"
        )

        # Get the first generated image
        image = images[0]

        # Convert to base64
        buffer = io.BytesIO()
        image._pil_image.save(buffer, format="PNG")
        image_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')

        return {
            "image_data": image_base64,
            "width": image._pil_image.width,
            "height": image._pil_image.height
        }
```

## 4. API Response Handling

### 4.1 Response Structure

Gemini API responses vary by model. Handle multiple response formats:

```python
def extract_image_from_response(response) -> bytes:
    """Extract image bytes from various Gemini response formats."""

    # Format 1: Inline data
    if hasattr(response, 'candidates'):
        for candidate in response.candidates:
            for part in candidate.content.parts:
                if hasattr(part, 'inline_data'):
                    return part.inline_data.data

    # Format 2: Generated images array
    if hasattr(response, 'generated_images'):
        return response.generated_images[0].image_bytes

    # Format 3: Direct image data
    if hasattr(response, 'image'):
        return response.image

    raise ValueError("Could not extract image from response")
```

### 4.2 Image Post-Processing

Ensure consistent output format:

```python
def process_image(image_bytes: bytes, target_size: int = 512) -> bytes:
    """
    Process generated image to ensure consistent format.

    Args:
        image_bytes: Raw image bytes
        target_size: Target dimension (square)

    Returns:
        Processed PNG image bytes
    """
    image = Image.open(io.BytesIO(image_bytes))

    # Convert to RGB if necessary
    if image.mode != 'RGB':
        image = image.convert('RGB')

    # Resize if needed
    if image.size != (target_size, target_size):
        image = image.resize((target_size, target_size), Image.LANCZOS)

    # Save as PNG
    buffer = io.BytesIO()
    image.save(buffer, format='PNG', optimize=True)

    return buffer.getvalue()
```

## 5. Error Handling

### 5.1 Retry Logic

Implement exponential backoff for transient errors:

```python
import asyncio
from functools import wraps

def with_retry(max_retries: int = 2, base_delay: float = 1.0):
    """Decorator for retry logic with exponential backoff."""

    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            last_exception = None

            for attempt in range(max_retries + 1):
                try:
                    return await func(*args, **kwargs)
                except (ConnectionError, TimeoutError) as e:
                    last_exception = e
                    if attempt < max_retries:
                        delay = base_delay * (2 ** attempt)
                        await asyncio.sleep(delay)

            raise last_exception

        return wrapper
    return decorator
```

### 5.2 Error Types

Map Gemini errors to application errors:

```python
def handle_gemini_error(error: Exception) -> dict:
    """Convert Gemini errors to standardized error response."""

    error_str = str(error).lower()

    if "quota" in error_str or "rate" in error_str:
        return {
            "code": "RATE_LIMIT_EXCEEDED",
            "message": "API rate limit exceeded. Please try again later.",
            "retry_after_seconds": 60
        }

    if "invalid" in error_str and "api key" in error_str:
        return {
            "code": "CONFIGURATION_ERROR",
            "message": "Service configuration error",
            "retry_after_seconds": None
        }

    if "timeout" in error_str:
        return {
            "code": "GENERATION_TIMEOUT",
            "message": "Image generation timed out. Please try again.",
            "retry_after_seconds": 5
        }

    if "safety" in error_str or "blocked" in error_str:
        return {
            "code": "CONTENT_FILTERED",
            "message": "Unable to generate image for this input. Please try different wording.",
            "retry_after_seconds": None
        }

    # Default error
    return {
        "code": "GENERATION_SERVICE_ERROR",
        "message": "Image generation service is temporarily unavailable",
        "retry_after_seconds": 30
    }
```

## 6. Testing

### 6.1 Mock Service for Development

```python
class MockGeminiService:
    """Mock service for development without API calls."""

    async def generate_image(self, prompt: str) -> dict:
        """Return a placeholder image."""
        # Create a simple gradient image as placeholder
        image = Image.new('RGB', (512, 512), color='#E8F4FC')

        buffer = io.BytesIO()
        image.save(buffer, format='PNG')
        image_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')

        return {
            "image_data": image_base64,
            "width": 512,
            "height": 512
        }

    async def health_check(self) -> dict:
        return {"status": "healthy", "latency_ms": 0}
```

### 6.2 Integration Test

```python
import pytest

@pytest.mark.asyncio
async def test_generate_image():
    service = GeminiService()
    result = await service.generate_image(
        "Abstract art with soft blue and pink colors, symmetrical composition"
    )

    assert "image_data" in result
    assert result["width"] > 0
    assert result["height"] > 0

    # Verify base64 is valid
    image_bytes = base64.b64decode(result["image_data"])
    image = Image.open(io.BytesIO(image_bytes))
    assert image.format == "PNG"
```

## 7. Configuration Reference

| Environment Variable | Required | Default | Description |
|---------------------|----------|---------|-------------|
| `GEMINI_API_KEY` | Yes | - | Google Gemini API key |
| `GEMINI_MODEL` | No | `gemini-2.0-flash-exp` | Model to use |
| `GEMINI_TIMEOUT_SECONDS` | No | `30` | Request timeout |
| `GEMINI_MAX_RETRIES` | No | `2` | Max retry attempts |
| `GCP_PROJECT_ID` | For Vertex | - | GCP project (if using Vertex AI) |
| `GCP_LOCATION` | For Vertex | `us-central1` | GCP region |

## 8. Cost Considerations

- Monitor API usage in Google Cloud Console
- Image generation is more expensive than text generation
- Consider implementing caching for identical prompts (future enhancement)
- Set up billing alerts in GCP
