"""
Visualization API Endpoints (Version 2.1)

Handles mood visualization image generation with two specialized endpoints:
- /feeling - Abstract art from emotions
- /story - 2D cartoon/infographic from text + emotions (with story analysis)
"""

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, field_validator, model_validator
from typing import Optional, List, Dict, Any
from datetime import datetime
import logging

from app.services.gemini_client import gemini_client, GeminiAPIError
from app.services.prompt_builder import prompt_builder, VALID_EMOTIONS, VALID_CATEGORIES
from app.services.story_analyzer import story_analyzer

router = APIRouter()
logger = logging.getLogger(__name__)


# Request/Response Models

class FeelingVisualizationRequest(BaseModel):
    """Request model for feeling visualization (abstract art from emotions)."""
    feeling_category: str
    selected_emotions: List[str]

    @field_validator('feeling_category')
    @classmethod
    def validate_feeling_category(cls, v):
        if v not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category '{v}'. Must be one of: {list(VALID_CATEGORIES)}")
        return v

    @field_validator('selected_emotions')
    @classmethod
    def validate_selected_emotions(cls, v):
        if not v:
            raise ValueError("At least one emotion must be selected")
        invalid = [e for e in v if e not in VALID_EMOTIONS]
        if invalid:
            raise ValueError(f"Invalid emotions: {invalid}. Valid: {list(VALID_EMOTIONS)}")
        return v


class StoryVisualizationRequest(BaseModel):
    """Request model for story visualization (2D cartoon from text + emotions)."""
    story_text: str
    feeling_category: str
    selected_emotions: List[str]

    @field_validator('story_text')
    @classmethod
    def validate_story_text(cls, v):
        text = v.strip() if v else ""
        if len(text) < 50:
            raise ValueError(f"Story text must be at least 50 characters (got {len(text)})")
        if len(text) > 5000:
            raise ValueError(f"Story text exceeds maximum length of 5000 characters (got {len(text)})")
        return text

    @field_validator('feeling_category')
    @classmethod
    def validate_feeling_category(cls, v):
        if v not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category '{v}'. Must be one of: {list(VALID_CATEGORIES)}")
        return v

    @field_validator('selected_emotions')
    @classmethod
    def validate_selected_emotions(cls, v):
        if not v:
            raise ValueError("Selected emotions are required to understand your story")
        invalid = [e for e in v if e not in VALID_EMOTIONS]
        if invalid:
            raise ValueError(f"Invalid emotions: {invalid}. Valid: {list(VALID_EMOTIONS)}")
        return v


class ImageSize(BaseModel):
    width: int
    height: int


class VisualizationData(BaseModel):
    """Response data for feeling visualization."""
    image_data: str
    image_format: str = "png"
    image_size: ImageSize
    prompt_used: str
    dominant_colors: List[str]
    generation_time_ms: int


class EmotionalFactor(BaseModel):
    """An emotional factor identified in the story."""
    factor: str
    description: str


class StoryAnalysis(BaseModel):
    """AI-generated analysis of the user's story."""
    central_stressor: str
    factors: List[EmotionalFactor]
    language: str


class StoryVisualizationData(BaseModel):
    """Response data for story visualization (includes story_analysis)."""
    image_data: str
    image_format: str = "png"
    image_size: ImageSize
    prompt_used: str
    dominant_colors: List[str]
    story_analysis: StoryAnalysis
    generation_time_ms: int


class VisualizationResponse(BaseModel):
    """Response for feeling visualization."""
    success: bool
    data: Optional[VisualizationData] = None
    error: Optional[Dict[str, Any]] = None
    meta: Dict[str, Any]


class StoryVisualizationResponse(BaseModel):
    """Response for story visualization."""
    success: bool
    data: Optional[StoryVisualizationData] = None
    error: Optional[Dict[str, Any]] = None
    meta: Dict[str, Any]


class HealthCheckResponse(BaseModel):
    status: str
    checks: Dict[str, Any]
    timestamp: str


# Helper function for error handling
def handle_generation_error(e: Exception, context: str = "visualization"):
    """Handle errors during image generation."""
    if isinstance(e, GeminiAPIError):
        error_str = str(e).lower()

        if "timeout" in error_str:
            status_code = 504
            error_code = "GENERATION_TIMEOUT"
            message = "Image generation timed out. Please try again."
        elif "safety" in error_str or "filter" in error_str:
            status_code = 400
            error_code = "CONTENT_FILTERED"
            message = "Unable to create visualization for this input. Please try different wording."
        elif "api key" in error_str:
            status_code = 503
            error_code = "CONFIGURATION_ERROR"
            message = "Service configuration error. Please contact support."
        else:
            status_code = 503
            error_code = "GENERATION_SERVICE_ERROR"
            message = "Image generation service is temporarily unavailable."

        logger.error(f"{context} generation failed: {e}")

        raise HTTPException(
            status_code=status_code,
            detail={
                "success": False,
                "error": {
                    "code": error_code,
                    "message": message,
                    "details": {
                        "suggestion": "Please try again in a few moments"
                    }
                },
                "meta": {
                    "timestamp": datetime.utcnow().isoformat() + "Z"
                }
            }
        )

    elif isinstance(e, ValueError):
        error_str = str(e)
        # Check for text too short error
        if "at least 50 characters" in error_str:
            error_code = "TEXT_TOO_SHORT"
            message = "Please share more about your feelings"
        else:
            error_code = "VALIDATION_ERROR"
            message = str(e)

        logger.warning(f"Validation error: {e}")
        raise HTTPException(
            status_code=400,
            detail={
                "success": False,
                "error": {
                    "code": error_code,
                    "message": message,
                    "details": {}
                },
                "meta": {
                    "timestamp": datetime.utcnow().isoformat() + "Z"
                }
            }
        )

    else:
        logger.exception(f"Unexpected error during {context}: {e}")
        raise HTTPException(
            status_code=500,
            detail={
                "success": False,
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "An unexpected error occurred",
                    "details": {
                        "suggestion": "Please try again later"
                    }
                },
                "meta": {
                    "timestamp": datetime.utcnow().isoformat() + "Z"
                }
            }
        )


# Endpoints

@router.post("/feeling", response_model=VisualizationResponse)
async def generate_feeling_visualization(request: FeelingVisualizationRequest):
    """
    Generate an abstract mood visualization from selected emotions.

    This is the first visualization in the user journey - draws feelings as abstract art.

    - **feeling_category**: Required category: "good", "bad", or "not_sure"
    - **selected_emotions**: Required list of emotion IDs (at least one)
    """
    try:
        logger.info(f"Generating feeling visualization: emotions={request.selected_emotions}, "
                   f"category={request.feeling_category}")

        # Build the prompt for abstract art
        prompt = prompt_builder.build_feeling_prompt(
            feeling_category=request.feeling_category,
            selected_emotions=request.selected_emotions
        )

        logger.debug(f"Generated prompt: {prompt[:200]}...")

        # Generate image
        result = await gemini_client.generate_visualization_image(prompt)

        # Extract dominant colors from the emotions for firework animation
        dominant_colors = prompt_builder.get_dominant_colors(request.selected_emotions)

        return VisualizationResponse(
            success=True,
            data=VisualizationData(
                image_data=result["image_data"],
                image_format="png",
                image_size=ImageSize(
                    width=result["width"],
                    height=result["height"]
                ),
                prompt_used=prompt,
                dominant_colors=dominant_colors,
                generation_time_ms=result["generation_time_ms"]
            ),
            meta={
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "api_version": "2.0"
            }
        )

    except Exception as e:
        handle_generation_error(e, "feeling visualization")


@router.post("/story", response_model=StoryVisualizationResponse)
async def generate_story_visualization(request: StoryVisualizationRequest):
    """
    Generate a story visualization from text and emotions.

    This is the second visualization - AI analyzes text to create a 2D cartoon/infographic
    illustrating the reasons behind the user's feelings.

    Features (v2.1):
    - Analyzes story text to identify central stressor and emotional factors
    - Returns story_analysis with labels in the detected language
    - Generates cartoon/infographic style image (no text labels in image)

    - **story_text**: Required text (min 50 chars, max 5000 chars)
    - **feeling_category**: Required category: "good", "bad", or "not_sure"
    - **selected_emotions**: Required list of emotion IDs
    """
    try:
        logger.info(f"Generating story visualization: emotions={request.selected_emotions}, "
                   f"category={request.feeling_category}, text_length={len(request.story_text)}")

        # Step 1: Analyze the story text using Gemini
        logger.info("Analyzing story text...")
        analysis_result = await story_analyzer.analyze_story(
            story_text=request.story_text,
            selected_emotions=request.selected_emotions
        )

        # Step 2: Build the prompt for story visualization (2D cartoon/infographic)
        prompt = prompt_builder.build_story_prompt(
            story_text=request.story_text,
            feeling_category=request.feeling_category,
            selected_emotions=request.selected_emotions,
            central_stressor=analysis_result.get("central_stressor"),
            factors=analysis_result.get("factors", [])
        )

        logger.debug(f"Generated prompt: {prompt[:200]}...")

        # Step 3: Generate image
        result = await gemini_client.generate_visualization_image(prompt)

        # Extract dominant colors from the emotions for firework animation
        dominant_colors = prompt_builder.get_dominant_colors(request.selected_emotions)

        # Build story analysis response
        story_analysis = StoryAnalysis(
            central_stressor=analysis_result.get("central_stressor", ""),
            factors=[
                EmotionalFactor(
                    factor=f.get("factor", ""),
                    description=f.get("description", "")
                )
                for f in analysis_result.get("factors", [])
            ],
            language=analysis_result.get("language", "en")
        )

        return StoryVisualizationResponse(
            success=True,
            data=StoryVisualizationData(
                image_data=result["image_data"],
                image_format="png",
                image_size=ImageSize(
                    width=result["width"],
                    height=result["height"]
                ),
                prompt_used=prompt,
                dominant_colors=dominant_colors,
                story_analysis=story_analysis,
                generation_time_ms=result["generation_time_ms"]
            ),
            meta={
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "api_version": "2.1"
            }
        )

    except Exception as e:
        handle_generation_error(e, "story visualization")


@router.get("/health", response_model=HealthCheckResponse)
async def visualization_health():
    """
    Check health of the visualization service.

    Verifies connectivity to Gemini API.
    """
    gemini_health = await gemini_client.check_visualization_health()

    overall_status = "healthy" if gemini_health["status"] == "healthy" else "degraded"

    return HealthCheckResponse(
        status=overall_status,
        checks={
            "gemini_api": gemini_health
        },
        timestamp=datetime.utcnow().isoformat() + "Z"
    )


@router.get("/emotions")
async def list_emotions():
    """
    Get list of valid emotion IDs.

    Returns all emotion IDs that can be used in the visualization endpoints.
    """
    positive = ["super_happy", "pumped", "cozy", "chill", "content"]
    negative = ["fuming", "freaked_out", "mad_as_hell", "blah", "down", "bored_stiff"]

    return {
        "success": True,
        "data": {
            "positive_emotions": positive,
            "negative_emotions": negative,
            "all_emotions": positive + negative
        },
        "meta": {
            "timestamp": datetime.utcnow().isoformat() + "Z"
        }
    }
