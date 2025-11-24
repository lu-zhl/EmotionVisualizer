from pydantic import BaseModel, Field, validator
from datetime import datetime
from decimal import Decimal
from typing import List, Optional
from uuid import UUID


VALID_EMOTIONS = [
    'joy', 'sadness', 'anger', 'fear', 'disgust', 'surprise',
    'anxiety', 'contentment', 'frustration', 'excitement'
]


class EmotionEntryCreate(BaseModel):
    situation: str = Field(..., min_length=1, max_length=5000)
    emotions: List[str] = Field(..., min_items=1, max_items=10)
    intensity: Decimal = Field(..., ge=0, le=1)
    notes: str = Field(default="", max_length=10000)

    @validator('emotions')
    def validate_emotions(cls, v):
        for emotion in v:
            if emotion not in VALID_EMOTIONS:
                raise ValueError(f'Invalid emotion: {emotion}')
        return v

    @validator('intensity')
    def round_intensity(cls, v):
        return round(v, 2)


class EmotionEntryUpdate(BaseModel):
    situation: Optional[str] = Field(None, min_length=1, max_length=5000)
    emotions: Optional[List[str]] = Field(None, min_items=1, max_items=10)
    intensity: Optional[Decimal] = Field(None, ge=0, le=1)
    notes: Optional[str] = Field(None, max_length=10000)

    @validator('emotions')
    def validate_emotions(cls, v):
        if v is not None:
            for emotion in v:
                if emotion not in VALID_EMOTIONS:
                    raise ValueError(f'Invalid emotion: {emotion}')
        return v

    @validator('intensity')
    def round_intensity(cls, v):
        if v is not None:
            return round(v, 2)
        return v


class EmotionEntryResponse(BaseModel):
    id: UUID
    situation: str
    emotions: List[str]
    intensity: Decimal
    notes: Optional[str]
    created_at: datetime
    updated_at: Optional[datetime]
    has_visualization: bool = False
    visualization_id: Optional[UUID] = None

    class Config:
        from_attributes = True
