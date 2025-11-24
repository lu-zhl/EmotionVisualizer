from sqlalchemy import Column, String, Text, DECIMAL, DateTime, ForeignKey, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship, validates
from sqlalchemy.sql import func
import uuid
from app.db.base import Base


VALID_EMOTIONS = [
    'joy', 'sadness', 'anger', 'fear', 'disgust', 'surprise',
    'anxiety', 'contentment', 'frustration', 'excitement'
]


class EmotionEntry(Base):
    __tablename__ = "emotion_entries"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, index=True)
    situation = Column(Text, nullable=False)
    emotions = Column(ARRAY(String), nullable=False)
    intensity = Column(DECIMAL(3, 2), nullable=False)
    notes = Column(Text, nullable=True)
    source = Column(String(50), default="manual")
    intake_session_id = Column(UUID(as_uuid=True), ForeignKey("intake_sessions.id"), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), index=True)
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="emotion_entries")
    visualization = relationship("Visualization", back_populates="emotion_entry", uselist=False, cascade="all, delete-orphan")
    intake_session = relationship("IntakeSession", back_populates="emotion_entry")

    @validates('intensity')
    def validate_intensity(self, key, value):
        if not (0 <= float(value) <= 1):
            raise ValueError("Intensity must be between 0 and 1")
        return value

    @validates('emotions')
    def validate_emotions(self, key, value):
        if not value or len(value) == 0:
            raise ValueError("At least one emotion must be specified")
        for emotion in value:
            if emotion not in VALID_EMOTIONS:
                raise ValueError(f"Invalid emotion: {emotion}")
        return value
