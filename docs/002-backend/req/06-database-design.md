# Database Design Specification

## Document Information
- **Milestone**: 002-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-24
- **Version**: 1.0

## Overview

This document specifies the database schema for the EmotionVisualizer backend using PostgreSQL with SQLAlchemy ORM.

**Database**: PostgreSQL 15+
**ORM**: SQLAlchemy 2.0+ (async)
**Migrations**: Alembic

## Entity Relationship Diagram

```
┌─────────────┐
│    users    │
└──────┬──────┘
       │ 1
       │
       │ *
┌──────┴──────────────┐
│  emotion_entries    │
└──────┬──────────────┘
       │ 1
       │
       │ 1 (optional)
┌──────┴──────────────┐
│  visualizations     │
└─────────────────────┘

Additional tables:
- intake_sessions (for dynamic intake flow)
- emotion_analytics (computed/cached analytics)
```

## Core Tables

### users

Stores user account information.

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    hashed_password VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    is_verified BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    last_login_at TIMESTAMP WITH TIME ZONE,

    -- Indexes
    CONSTRAINT users_email_check CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}$')
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created_at ON users(created_at DESC);
```

**SQLAlchemy Model**:
```python
from sqlalchemy import Column, String, Boolean, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
import uuid

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=False, index=True)
    hashed_password = Column(String(255), nullable=False)
    name = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    is_verified = Column(Boolean, default=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
    last_login_at = Column(DateTime(timezone=True), nullable=True)

    # Relationships
    emotion_entries = relationship("EmotionEntry", back_populates="user", cascade="all, delete-orphan")
    intake_sessions = relationship("IntakeSession", back_populates="user", cascade="all, delete-orphan")
```

### emotion_entries

Stores user's emotion entries.

```sql
CREATE TABLE emotion_entries (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    situation TEXT NOT NULL,
    emotions TEXT[] NOT NULL,  -- Array of emotion identifiers
    intensity DECIMAL(3,2) NOT NULL CHECK (intensity >= 0 AND intensity <= 1),
    notes TEXT,
    source VARCHAR(50) DEFAULT 'manual',  -- manual, intake_flow, import
    intake_session_id UUID,  -- Link to intake session if created via dynamic flow
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT emotions_not_empty CHECK (array_length(emotions, 1) > 0)
);

CREATE INDEX idx_emotion_entries_user_id ON emotion_entries(user_id);
CREATE INDEX idx_emotion_entries_created_at ON emotion_entries(created_at DESC);
CREATE INDEX idx_emotion_entries_emotions ON emotion_entries USING GIN(emotions);
CREATE INDEX idx_emotion_entries_user_created ON emotion_entries(user_id, created_at DESC);
```

**SQLAlchemy Model**:
```python
from sqlalchemy import Column, String, Text, DECIMAL, DateTime, ForeignKey, ARRAY
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
import uuid

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

    # Validations in Python
    @validates('intensity')
    def validate_intensity(self, key, value):
        if not (0 <= value <= 1):
            raise ValueError("Intensity must be between 0 and 1")
        return value

    @validates('emotions')
    def validate_emotions(self, key, value):
        if not value or len(value) == 0:
            raise ValueError("At least one emotion must be specified")
        valid_emotions = ['joy', 'sadness', 'anger', 'fear', 'disgust', 'surprise',
                          'anxiety', 'contentment', 'frustration', 'excitement']
        for emotion in value:
            if emotion not in valid_emotions:
                raise ValueError(f"Invalid emotion: {emotion}")
        return value
```

### visualizations

Stores generated visualizations.

```sql
CREATE TABLE visualizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    entry_id UUID UNIQUE NOT NULL REFERENCES emotion_entries(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',  -- pending, processing, completed, failed
    style VARCHAR(50) DEFAULT 'abstract',  -- abstract, diagram, metaphor
    image_url TEXT,
    thumbnail_url TEXT,
    summary TEXT,
    insights TEXT[],  -- Array of insight strings
    visual_elements JSONB,  -- Flexible JSON storage for visual metadata
    error_message TEXT,
    gemini_analysis JSONB,  -- Store Gemini API response
    nanobanana_response JSONB,  -- Store NanaBanana API response
    processing_started_at TIMESTAMP WITH TIME ZONE,
    processing_completed_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    -- Constraints
    CONSTRAINT status_check CHECK (status IN ('pending', 'processing', 'completed', 'failed'))
);

CREATE INDEX idx_visualizations_entry_id ON visualizations(entry_id);
CREATE INDEX idx_visualizations_user_id ON visualizations(user_id);
CREATE INDEX idx_visualizations_status ON visualizations(status);
CREATE INDEX idx_visualizations_created_at ON visualizations(created_at DESC);
```

**SQLAlchemy Model**:
```python
from sqlalchemy import Column, String, Text, DateTime, ForeignKey, ARRAY
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
import uuid

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
```

### intake_sessions

Stores dynamic intake flow sessions.

```sql
CREATE TABLE intake_sessions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    initial_situation TEXT NOT NULL,
    conversation_history JSONB NOT NULL DEFAULT '[]',  -- Array of Q&A exchanges
    current_step INTEGER DEFAULT 1,
    is_complete BOOLEAN DEFAULT FALSE,
    ai_context JSONB,  -- Gemini's understanding of the situation
    final_summary TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    completed_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_intake_sessions_user_id ON intake_sessions(user_id);
CREATE INDEX idx_intake_sessions_created_at ON intake_sessions(created_at DESC);
CREATE INDEX idx_intake_sessions_is_complete ON intake_sessions(is_complete);
```

**SQLAlchemy Model**:
```python
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
```

## Supporting Tables

### emotion_analytics (Materialized View / Table)

Pre-computed analytics for faster queries.

```sql
CREATE TABLE emotion_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    period_end DATE NOT NULL,
    emotion_counts JSONB NOT NULL,  -- {"anxiety": 5, "joy": 3, ...}
    average_intensity DECIMAL(3,2),
    total_entries INTEGER,
    most_common_emotions TEXT[],
    insights TEXT[],
    computed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

    UNIQUE(user_id, period_start, period_end)
);

CREATE INDEX idx_emotion_analytics_user_id ON emotion_analytics(user_id);
CREATE INDEX idx_emotion_analytics_period ON emotion_analytics(period_start, period_end);
```

### api_keys (Optional - for future multi-client support)

```sql
CREATE TABLE api_keys (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    key_hash VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    scopes TEXT[] DEFAULT ARRAY['read', 'write'],
    is_active BOOLEAN DEFAULT TRUE,
    last_used_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_api_keys_user_id ON api_keys(user_id);
CREATE INDEX idx_api_keys_key_hash ON api_keys(key_hash);
```

## Data Types & Enums

### Valid Emotions
```python
VALID_EMOTIONS = [
    'joy',
    'sadness',
    'anger',
    'fear',
    'disgust',
    'surprise',
    'anxiety',
    'contentment',
    'frustration',
    'excitement'
]
```

### Visualization Status
```python
class VisualizationStatus(str, Enum):
    PENDING = "pending"
    PROCESSING = "processing"
    COMPLETED = "completed"
    FAILED = "failed"
```

### Visualization Style
```python
class VisualizationStyle(str, Enum):
    ABSTRACT = "abstract"
    DIAGRAM = "diagram"
    METAPHOR = "metaphor"
```

## Indexes Strategy

### Performance Indexes

```sql
-- User queries
CREATE INDEX idx_users_email ON users(email);

-- Entry queries (most common)
CREATE INDEX idx_emotion_entries_user_created ON emotion_entries(user_id, created_at DESC);
CREATE INDEX idx_emotion_entries_emotions_gin ON emotion_entries USING GIN(emotions);

-- Visualization queries
CREATE INDEX idx_visualizations_user_status ON visualizations(user_id, status);

-- Analytics queries
CREATE INDEX idx_emotion_entries_user_date_range ON emotion_entries(user_id, created_at) WHERE created_at >= NOW() - INTERVAL '90 days';
```

### Partial Indexes (for common filters)

```sql
-- Active visualizations
CREATE INDEX idx_visualizations_active ON visualizations(user_id, created_at DESC)
WHERE status IN ('pending', 'processing');

-- Incomplete intake sessions
CREATE INDEX idx_intake_sessions_incomplete ON intake_sessions(user_id, updated_at DESC)
WHERE is_complete = FALSE;
```

## Constraints & Validation

### Database-Level Constraints

1. **Foreign Keys**: All with `ON DELETE CASCADE` for data integrity
2. **Check Constraints**:
   - Intensity between 0 and 1
   - Emotions array not empty
   - Valid status values
3. **Unique Constraints**:
   - User email
   - One visualization per entry

### Application-Level Validation

```python
# Pydantic schemas for API validation
from pydantic import BaseModel, validator, Field
from typing import List
from decimal import Decimal

class EmotionEntryCreate(BaseModel):
    situation: str = Field(..., min_length=1, max_length=5000)
    emotions: List[str] = Field(..., min_items=1, max_items=10)
    intensity: Decimal = Field(..., ge=0, le=1)
    notes: str = Field(default="", max_length=10000)

    @validator('emotions')
    def validate_emotions(cls, v):
        valid_emotions = ['joy', 'sadness', 'anger', 'fear', 'disgust',
                          'surprise', 'anxiety', 'contentment', 'frustration', 'excitement']
        for emotion in v:
            if emotion not in valid_emotions:
                raise ValueError(f'Invalid emotion: {emotion}')
        return v

    @validator('intensity')
    def round_intensity(cls, v):
        return round(v, 2)
```

## Migrations Strategy

### Alembic Configuration

```python
# alembic/env.py
from sqlalchemy import engine_from_config, pool
from app.models import Base  # Import all models
from app.core.config import settings

config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)
target_metadata = Base.metadata

def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )
    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
            compare_type=True,
            compare_server_default=True
        )
        with context.begin_transaction():
            context.run_migrations()
```

### Migration Naming Convention

```
YYYYMMDD_HHMM_description.py

Examples:
- 20251124_1200_create_users_table.py
- 20251124_1205_create_emotion_entries_table.py
- 20251124_1210_add_intake_sessions.py
```

### Sample Migration

```python
"""create emotion_entries table

Revision ID: abc123def456
Revises: previous_revision
Create Date: 2025-11-24 12:05:00

"""
from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects import postgresql

revision = 'abc123def456'
down_revision = 'previous_revision'

def upgrade():
    op.create_table(
        'emotion_entries',
        sa.Column('id', postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column('user_id', postgresql.UUID(as_uuid=True), nullable=False),
        sa.Column('situation', sa.Text(), nullable=False),
        sa.Column('emotions', postgresql.ARRAY(sa.String()), nullable=False),
        sa.Column('intensity', sa.DECIMAL(3, 2), nullable=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('source', sa.String(50), default='manual'),
        sa.Column('created_at', sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column('updated_at', sa.DateTime(timezone=True), onupdate=sa.func.now()),
        sa.ForeignKeyConstraint(['user_id'], ['users.id'], ondelete='CASCADE'),
        sa.CheckConstraint('intensity >= 0 AND intensity <= 1', name='intensity_range'),
        sa.CheckConstraint('array_length(emotions, 1) > 0', name='emotions_not_empty')
    )
    op.create_index('idx_emotion_entries_user_id', 'emotion_entries', ['user_id'])
    op.create_index('idx_emotion_entries_created_at', 'emotion_entries', ['created_at'], postgresql_ops={'created_at': 'DESC'})

def downgrade():
    op.drop_table('emotion_entries')
```

## Data Seeding

### Development Seed Data

```python
# seeds/dev_data.py
async def seed_dev_data(session: AsyncSession):
    # Create test user
    test_user = User(
        email="test@example.com",
        hashed_password=get_password_hash("Test123!"),
        name="Test User"
    )
    session.add(test_user)
    await session.flush()

    # Create sample entries
    entries = [
        EmotionEntry(
            user_id=test_user.id,
            situation="Morning presentation at work",
            emotions=["anxiety", "excitement"],
            intensity=Decimal("0.7"),
            notes="Big presentation coming up"
        ),
        # ... more entries
    ]
    session.add_all(entries)
    await session.commit()
```

## Backup & Recovery

### Backup Strategy

```bash
# Daily backups
pg_dump -h localhost -U emotionviz -d emotionviz_db -F c -f backup_$(date +%Y%m%d).dump

# Backup with compression
pg_dump -h localhost -U emotionviz -d emotionviz_db | gzip > backup_$(date +%Y%m%d).sql.gz
```

### Restore

```bash
# Restore from custom format
pg_restore -h localhost -U emotionviz -d emotionviz_db backup_20251124.dump

# Restore from SQL
gunzip -c backup_20251124.sql.gz | psql -h localhost -U emotionviz -d emotionviz_db
```

## Performance Considerations

### Query Optimization

1. **Always use indexes** for user_id + created_at queries
2. **Limit result sets** with pagination
3. **Use JSONB indexes** for frequently queried JSON fields
4. **Connection pooling** via SQLAlchemy (20-40 connections)

### Monitoring Queries

```sql
-- Slow queries
SELECT query, mean_exec_time, calls
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Index usage
SELECT schemaname, tablename, indexname, idx_scan, idx_tup_read, idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;
```

## Security

### Data Protection

1. **Passwords**: Hashed with bcrypt (via passlib)
2. **PII**: Email addresses stored securely
3. **API Keys**: Hashed before storage
4. **Access Control**: Row-level via user_id foreign keys

### SQL Injection Prevention

- ✅ SQLAlchemy ORM (parameterized queries)
- ✅ No raw SQL execution
- ✅ Input validation with Pydantic

## Next Steps

1. Review database design
2. Create initial Alembic migrations
3. Implement SQLAlchemy models
4. Add Pydantic schemas
5. Create seed data scripts
6. Test database operations
