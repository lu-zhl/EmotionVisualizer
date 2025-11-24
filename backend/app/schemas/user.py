from pydantic import BaseModel, EmailStr, Field
from datetime import datetime
from typing import Optional
from uuid import UUID


class UserCreate(BaseModel):
    email: EmailStr
    password: str = Field(..., min_length=8)
    name: str = Field(..., min_length=1, max_length=255)


class UserLogin(BaseModel):
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    id: UUID
    email: str
    name: str
    is_active: bool
    created_at: datetime
    entry_count: Optional[int] = 0
    visualization_count: Optional[int] = 0

    class Config:
        from_attributes = True
