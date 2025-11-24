from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from uuid import UUID
from typing import List

from app.db.session import get_db
from app.models.user import User
from app.models.emotion_entry import EmotionEntry
from app.schemas.emotion_entry import EmotionEntryCreate, EmotionEntryUpdate, EmotionEntryResponse
from app.api.deps import get_current_user

router = APIRouter()


@router.get("", response_model=dict)
async def list_entries(
    limit: int = Query(50, ge=1, le=100),
    offset: int = Query(0, ge=0),
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """List all emotion entries for the authenticated user"""
    # Get total count
    count_result = await db.execute(
        select(func.count()).select_from(EmotionEntry).where(EmotionEntry.user_id == current_user.id)
    )
    total = count_result.scalar()

    # Get entries
    result = await db.execute(
        select(EmotionEntry)
        .where(EmotionEntry.user_id == current_user.id)
        .order_by(EmotionEntry.created_at.desc())
        .limit(limit)
        .offset(offset)
    )
    entries = result.scalars().all()

    return {
        "success": True,
        "data": {
            "entries": [
                EmotionEntryResponse(
                    id=entry.id,
                    situation=entry.situation,
                    emotions=entry.emotions,
                    intensity=entry.intensity,
                    notes=entry.notes,
                    created_at=entry.created_at,
                    updated_at=entry.updated_at,
                    has_visualization=False
                )
                for entry in entries
            ],
            "total": total,
            "limit": limit,
            "offset": offset
        }
    }


@router.post("", response_model=dict, status_code=status.HTTP_201_CREATED)
async def create_entry(
    entry_data: EmotionEntryCreate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Create a new emotion entry"""
    new_entry = EmotionEntry(
        user_id=current_user.id,
        situation=entry_data.situation,
        emotions=entry_data.emotions,
        intensity=entry_data.intensity,
        notes=entry_data.notes
    )

    db.add(new_entry)
    await db.commit()
    await db.refresh(new_entry)

    return {
        "success": True,
        "data": {
            "entry": EmotionEntryResponse(
                id=new_entry.id,
                situation=new_entry.situation,
                emotions=new_entry.emotions,
                intensity=new_entry.intensity,
                notes=new_entry.notes,
                created_at=new_entry.created_at,
                updated_at=new_entry.updated_at,
                has_visualization=False
            )
        }
    }


@router.get("/{entry_id}", response_model=dict)
async def get_entry(
    entry_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Get a specific emotion entry"""
    result = await db.execute(
        select(EmotionEntry).where(
            EmotionEntry.id == entry_id,
            EmotionEntry.user_id == current_user.id
        )
    )
    entry = result.scalar_one_or_none()

    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Entry not found"
        )

    return {
        "success": True,
        "data": EmotionEntryResponse(
            id=entry.id,
            situation=entry.situation,
            emotions=entry.emotions,
            intensity=entry.intensity,
            notes=entry.notes,
            created_at=entry.created_at,
            updated_at=entry.updated_at,
            has_visualization=False
        )
    }


@router.put("/{entry_id}", response_model=dict)
async def update_entry(
    entry_id: UUID,
    entry_data: EmotionEntryUpdate,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Update an emotion entry"""
    result = await db.execute(
        select(EmotionEntry).where(
            EmotionEntry.id == entry_id,
            EmotionEntry.user_id == current_user.id
        )
    )
    entry = result.scalar_one_or_none()

    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Entry not found"
        )

    # Update fields
    if entry_data.situation is not None:
        entry.situation = entry_data.situation
    if entry_data.emotions is not None:
        entry.emotions = entry_data.emotions
    if entry_data.intensity is not None:
        entry.intensity = entry_data.intensity
    if entry_data.notes is not None:
        entry.notes = entry_data.notes

    await db.commit()
    await db.refresh(entry)

    return {
        "success": True,
        "data": EmotionEntryResponse(
            id=entry.id,
            situation=entry.situation,
            emotions=entry.emotions,
            intensity=entry.intensity,
            notes=entry.notes,
            created_at=entry.created_at,
            updated_at=entry.updated_at,
            has_visualization=False
        )
    }


@router.delete("/{entry_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_entry(
    entry_id: UUID,
    db: AsyncSession = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """Delete an emotion entry"""
    result = await db.execute(
        select(EmotionEntry).where(
            EmotionEntry.id == entry_id,
            EmotionEntry.user_id == current_user.id
        )
    )
    entry = result.scalar_one_or_none()

    if not entry:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Entry not found"
        )

    await db.delete(entry)
    await db.commit()
