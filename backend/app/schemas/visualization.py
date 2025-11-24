from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List, Dict, Any
from uuid import UUID


class VisualizationCreate(BaseModel):
    entry_id: UUID
    style: str = "abstract"


class VisualizationResponse(BaseModel):
    id: UUID
    entry_id: UUID
    status: str
    style: Optional[str]
    image_url: Optional[str]
    thumbnail_url: Optional[str]
    summary: Optional[str]
    insights: Optional[List[str]]
    visual_elements: Optional[Dict[str, Any]]
    error_message: Optional[str]
    created_at: datetime
    completed_at: Optional[datetime] = None
    estimated_time_seconds: Optional[int] = None
    progress: Optional[int] = None

    class Config:
        from_attributes = True
