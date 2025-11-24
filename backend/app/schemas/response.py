from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import datetime


class ErrorDetail(BaseModel):
    code: str
    message: str
    details: Optional[Dict[str, Any]] = None


class ResponseMeta(BaseModel):
    timestamp: datetime = datetime.utcnow()


class SuccessResponse(BaseModel):
    success: bool = True
    data: Dict[str, Any]
    meta: ResponseMeta = ResponseMeta()


class ErrorResponse(BaseModel):
    success: bool = False
    error: ErrorDetail
    meta: ResponseMeta = ResponseMeta()
