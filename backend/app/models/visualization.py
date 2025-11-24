from sqlalchemy import Column, String, Text, DateTime, ForeignKey, ARRAY
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.db.base import Base


class Visualization(Base):
    __tablename__ = "visualizations"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    entry_id = Column(UUID(as_uuid=True), ForeignKey("emotion_entries.id", ondelete="CASCADE"), unique=True, nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    status = Column(String(50), nullable=False, default="pending", index=True)
    style = Column(String(50), default="abstract")
    image_url = Column(Text, nullable=True)
    thumbnail_url = Column(Text, nullable=True)
    summary = Column(Text, nullable=True)
    insights = Column(ARRAY(Text), nullable=True)
    visual_elements = Column(JSONB, nullable=True)
    error_message = Column(Text, nullable=True)
    gemini_analysis = Column(JSONB, nullable=True)
    nanobanana_response = Column(JSONB, nullable=True)
    processing_started_at = Column(DateTime(timezone=True), nullable=True)
    processing_completed_at = Column(DateTime(timezone=True), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    emotion_entry = relationship("EmotionEntry", back_populates="visualization")
    user = relationship("User")
