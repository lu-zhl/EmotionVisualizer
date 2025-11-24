from sqlalchemy import Column, String, Text, Integer, Boolean, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
import uuid
from app.db.base import Base


class IntakeSession(Base):
    __tablename__ = "intake_sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    initial_situation = Column(Text, nullable=False)
    conversation_history = Column(JSONB, nullable=False, default=list)
    current_step = Column(Integer, default=1)
    is_complete = Column(Boolean, default=False, index=True)
    ai_context = Column(JSONB, nullable=True)
    final_summary = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    completed_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    user = relationship("User", back_populates="intake_sessions")
    emotion_entry = relationship("EmotionEntry", back_populates="intake_session", uselist=False)
