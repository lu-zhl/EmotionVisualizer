from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func
from datetime import datetime

from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserCreate, UserLogin, UserResponse
from app.schemas.token import Token
from app.core.security import get_password_hash, verify_password, create_access_token
from app.core.config import settings
from app.api.deps import get_current_user

router = APIRouter()


@router.post("/register", response_model=dict, status_code=status.HTTP_201_CREATED)
async def register(user_data: UserCreate, db: AsyncSession = Depends(get_db)):
    """Register a new user"""
    # Check if user exists
    result = await db.execute(select(User).where(User.email == user_data.email))
    existing_user = result.scalar_one_or_none()

    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already registered"
        )

    # Create new user
    new_user = User(
        email=user_data.email,
        hashed_password=get_password_hash(user_data.password),
        name=user_data.name
    )

    db.add(new_user)
    await db.commit()
    await db.refresh(new_user)

    # Create access token
    access_token = create_access_token(data={"sub": str(new_user.id)})

    return {
        "success": True,
        "data": {
            "user": UserResponse(
                id=new_user.id,
                email=new_user.email,
                name=new_user.name,
                is_active=new_user.is_active,
                created_at=new_user.created_at
            ),
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        }
    }


@router.post("/login", response_model=dict)
async def login(credentials: UserLogin, db: AsyncSession = Depends(get_db)):
    """Authenticate user and return access token"""
    result = await db.execute(select(User).where(User.email == credentials.email))
    user = result.scalar_one_or_none()

    if not user or not verify_password(credentials.password, user.hashed_password):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials"
        )

    if not user.is_active:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="User account is inactive"
        )

    # Update last login
    user.last_login_at = datetime.utcnow()
    await db.commit()

    # Create access token
    access_token = create_access_token(data={"sub": str(user.id)})

    return {
        "success": True,
        "data": {
            "access_token": access_token,
            "token_type": "bearer",
            "expires_in": settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            "user": UserResponse(
                id=user.id,
                email=user.email,
                name=user.name,
                is_active=user.is_active,
                created_at=user.created_at
            )
        }
    }


@router.get("/me", response_model=dict)
async def get_me(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    """Get current user information"""
    # Get entry and visualization counts
    entry_count_result = await db.execute(
        select(func.count()).select_from(User).join(User.emotion_entries).where(User.id == current_user.id)
    )
    entry_count = entry_count_result.scalar() or 0

    return {
        "success": True,
        "data": UserResponse(
            id=current_user.id,
            email=current_user.email,
            name=current_user.name,
            is_active=current_user.is_active,
            created_at=current_user.created_at,
            entry_count=entry_count,
            visualization_count=0
        )
    }
