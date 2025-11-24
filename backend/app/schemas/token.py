from pydantic import BaseModel
from app.schemas.user import UserResponse


class Token(BaseModel):
    access_token: str
    token_type: str
    expires_in: int
    user: UserResponse


class TokenData(BaseModel):
    user_id: str
