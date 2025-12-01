# Error Handling Guide

## Document Information
- **Milestone**: 004-mood-visualization-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-26
- **Version**: 1.0

---

## 1. Overview

This document defines error handling strategies for the mood visualization API, ensuring graceful degradation and meaningful error messages for both developers and end users.

## 2. Error Categories

### 2.1 Client Errors (4xx)

| Code | Name | When to Use |
|------|------|-------------|
| 400 | Bad Request | Invalid input, validation failures |
| 401 | Unauthorized | Missing/invalid auth (future) |
| 403 | Forbidden | Access denied (future) |
| 404 | Not Found | Resource doesn't exist |
| 422 | Unprocessable Entity | Valid JSON but semantic errors |
| 429 | Too Many Requests | Rate limit exceeded (future) |

### 2.2 Server Errors (5xx)

| Code | Name | When to Use |
|------|------|-------------|
| 500 | Internal Server Error | Unexpected server errors |
| 502 | Bad Gateway | Upstream service error |
| 503 | Service Unavailable | Gemini API down/overloaded |
| 504 | Gateway Timeout | Gemini API timeout |

## 3. Error Response Format

### 3.1 Standard Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "User-friendly error message",
    "details": {
      "field": "specific_field",
      "reason": "detailed_reason",
      "suggestion": "How to fix"
    }
  },
  "meta": {
    "timestamp": "2025-11-26T12:00:00Z",
    "request_id": "uuid",
    "api_version": "1.0"
  }
}
```

### 3.2 Error Code Reference

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Input validation failed |
| `EMPTY_INPUT` | 400 | No mood input provided |
| `INVALID_EMOTION` | 400 | Unknown emotion ID |
| `TEXT_TOO_LONG` | 400 | Free text exceeds limit |
| `INVALID_CATEGORY` | 400 | Invalid feeling category |
| `GENERATION_SERVICE_ERROR` | 503 | Gemini API failure |
| `GENERATION_TIMEOUT` | 504 | Generation took too long |
| `CONTENT_FILTERED` | 400 | Input blocked by safety filter |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests |
| `INTERNAL_ERROR` | 500 | Unexpected server error |

## 4. Validation Errors

### 4.1 Empty Input

**Condition**: Neither `free_text` nor `selected_emotions` provided

```json
{
  "success": false,
  "error": {
    "code": "EMPTY_INPUT",
    "message": "Please provide your mood input",
    "details": {
      "reason": "At least one of 'free_text' or 'selected_emotions' is required",
      "suggestion": "Enter how you're feeling in text or select emotions from the list"
    }
  }
}
```

### 4.2 Invalid Emotion ID

**Condition**: `selected_emotions` contains unknown ID

```json
{
  "success": false,
  "error": {
    "code": "INVALID_EMOTION",
    "message": "Some selected emotions are not recognized",
    "details": {
      "invalid_values": ["unknown_emotion"],
      "valid_values": ["super_happy", "pumped", "cozy", "chill", "content", "fuming", "freaked_out", "mad_as_hell", "blah", "down", "bored_stiff"]
    }
  }
}
```

### 4.3 Text Too Long

**Condition**: `free_text` exceeds 5000 characters

```json
{
  "success": false,
  "error": {
    "code": "TEXT_TOO_LONG",
    "message": "Your text is too long",
    "details": {
      "max_length": 5000,
      "actual_length": 5234,
      "suggestion": "Please shorten your text to 5000 characters or less"
    }
  }
}
```

### 4.4 Invalid Feeling Category

**Condition**: `feeling_category` not in allowed values

```json
{
  "success": false,
  "error": {
    "code": "INVALID_CATEGORY",
    "message": "Invalid feeling category",
    "details": {
      "provided": "unknown",
      "valid_values": ["good", "bad", "not_sure"]
    }
  }
}
```

## 5. Service Errors

### 5.1 Gemini API Unavailable

**Condition**: Cannot connect to Gemini API

```json
{
  "success": false,
  "error": {
    "code": "GENERATION_SERVICE_ERROR",
    "message": "Image generation is temporarily unavailable",
    "details": {
      "service": "gemini",
      "retry_after_seconds": 30,
      "suggestion": "Please try again in a few moments"
    }
  }
}
```

### 5.2 Generation Timeout

**Condition**: Image generation exceeds timeout (30s)

```json
{
  "success": false,
  "error": {
    "code": "GENERATION_TIMEOUT",
    "message": "Image generation is taking longer than expected",
    "details": {
      "timeout_seconds": 30,
      "suggestion": "Please try again. If the problem persists, try simpler input"
    }
  }
}
```

### 5.3 Content Filtered

**Condition**: Gemini safety filters blocked the request

```json
{
  "success": false,
  "error": {
    "code": "CONTENT_FILTERED",
    "message": "Unable to create visualization for this input",
    "details": {
      "reason": "Content safety check",
      "suggestion": "Please try describing your feelings differently"
    }
  }
}
```

### 5.4 Rate Limit (Future)

**Condition**: Too many requests

```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "You've made too many requests",
    "details": {
      "limit": 10,
      "period": "hour",
      "retry_after_seconds": 1800
    }
  }
}
```

## 6. Implementation

### 6.1 Custom Exception Classes

```python
from enum import Enum
from typing import Optional, Dict, Any

class ErrorCode(str, Enum):
    VALIDATION_ERROR = "VALIDATION_ERROR"
    EMPTY_INPUT = "EMPTY_INPUT"
    INVALID_EMOTION = "INVALID_EMOTION"
    TEXT_TOO_LONG = "TEXT_TOO_LONG"
    INVALID_CATEGORY = "INVALID_CATEGORY"
    GENERATION_SERVICE_ERROR = "GENERATION_SERVICE_ERROR"
    GENERATION_TIMEOUT = "GENERATION_TIMEOUT"
    CONTENT_FILTERED = "CONTENT_FILTERED"
    RATE_LIMIT_EXCEEDED = "RATE_LIMIT_EXCEEDED"
    INTERNAL_ERROR = "INTERNAL_ERROR"


class VisualizationError(Exception):
    """Base exception for visualization errors."""

    def __init__(
        self,
        code: ErrorCode,
        message: str,
        status_code: int = 400,
        details: Optional[Dict[str, Any]] = None
    ):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(message)

    def to_response(self) -> Dict[str, Any]:
        return {
            "success": False,
            "error": {
                "code": self.code.value,
                "message": self.message,
                "details": self.details
            }
        }


class ValidationError(VisualizationError):
    """Input validation error."""

    def __init__(self, message: str, details: Optional[Dict[str, Any]] = None):
        super().__init__(
            code=ErrorCode.VALIDATION_ERROR,
            message=message,
            status_code=400,
            details=details
        )


class EmptyInputError(VisualizationError):
    """No mood input provided."""

    def __init__(self):
        super().__init__(
            code=ErrorCode.EMPTY_INPUT,
            message="Please provide your mood input",
            status_code=400,
            details={
                "reason": "At least one of 'free_text' or 'selected_emotions' is required",
                "suggestion": "Enter how you're feeling in text or select emotions"
            }
        )


class GenerationServiceError(VisualizationError):
    """Gemini API error."""

    def __init__(self, retry_after: int = 30):
        super().__init__(
            code=ErrorCode.GENERATION_SERVICE_ERROR,
            message="Image generation is temporarily unavailable",
            status_code=503,
            details={
                "service": "gemini",
                "retry_after_seconds": retry_after,
                "suggestion": "Please try again in a few moments"
            }
        )


class GenerationTimeoutError(VisualizationError):
    """Generation took too long."""

    def __init__(self, timeout: int = 30):
        super().__init__(
            code=ErrorCode.GENERATION_TIMEOUT,
            message="Image generation is taking longer than expected",
            status_code=504,
            details={
                "timeout_seconds": timeout,
                "suggestion": "Please try again"
            }
        )


class ContentFilteredError(VisualizationError):
    """Content blocked by safety filter."""

    def __init__(self):
        super().__init__(
            code=ErrorCode.CONTENT_FILTERED,
            message="Unable to create visualization for this input",
            status_code=400,
            details={
                "reason": "Content safety check",
                "suggestion": "Please try describing your feelings differently"
            }
        )
```

### 6.2 FastAPI Exception Handler

```python
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from datetime import datetime
import uuid
import logging

app = FastAPI()
logger = logging.getLogger(__name__)


@app.exception_handler(VisualizationError)
async def visualization_error_handler(
    request: Request,
    exc: VisualizationError
) -> JSONResponse:
    """Handle custom visualization errors."""
    response = exc.to_response()
    response["meta"] = {
        "timestamp": datetime.utcnow().isoformat() + "Z",
        "request_id": str(uuid.uuid4()),
        "api_version": "1.0"
    }

    # Log error
    logger.warning(
        f"VisualizationError: {exc.code.value} - {exc.message}",
        extra={"details": exc.details}
    )

    return JSONResponse(
        status_code=exc.status_code,
        content=response
    )


@app.exception_handler(Exception)
async def generic_error_handler(
    request: Request,
    exc: Exception
) -> JSONResponse:
    """Handle unexpected errors."""
    # Log full error
    logger.error(f"Unexpected error: {str(exc)}", exc_info=True)

    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": {
                "code": "INTERNAL_ERROR",
                "message": "An unexpected error occurred",
                "details": {
                    "suggestion": "Please try again later"
                }
            },
            "meta": {
                "timestamp": datetime.utcnow().isoformat() + "Z",
                "request_id": str(uuid.uuid4()),
                "api_version": "1.0"
            }
        }
    )
```

### 6.3 Input Validation

```python
from pydantic import BaseModel, field_validator, model_validator
from typing import Optional, List

VALID_EMOTIONS = {
    "super_happy", "pumped", "cozy", "chill", "content",
    "fuming", "freaked_out", "mad_as_hell", "blah", "down", "bored_stiff"
}

VALID_CATEGORIES = {"good", "bad", "not_sure"}


class GenerateVisualizationRequest(BaseModel):
    free_text: Optional[str] = None
    feeling_category: Optional[str] = None
    selected_emotions: Optional[List[str]] = None

    @field_validator('free_text')
    @classmethod
    def validate_free_text(cls, v):
        if v is not None and len(v) > 5000:
            raise ValueError(f"Text exceeds maximum length of 5000 characters (got {len(v)})")
        return v

    @field_validator('feeling_category')
    @classmethod
    def validate_feeling_category(cls, v):
        if v is not None and v not in VALID_CATEGORIES:
            raise ValueError(f"Invalid category '{v}'. Must be one of: {VALID_CATEGORIES}")
        return v

    @field_validator('selected_emotions')
    @classmethod
    def validate_selected_emotions(cls, v):
        if v is not None:
            invalid = [e for e in v if e not in VALID_EMOTIONS]
            if invalid:
                raise ValueError(f"Invalid emotions: {invalid}")
        return v

    @model_validator(mode='after')
    def validate_has_input(self):
        if not self.free_text and not self.selected_emotions:
            raise EmptyInputError()
        return self
```

## 7. iOS Error Handling

### 7.1 Swift Error Models

```swift
struct APIErrorResponse: Codable {
    let success: Bool
    let error: APIError?

    struct APIError: Codable {
        let code: String
        let message: String
        let details: [String: AnyCodable]?
    }
}

enum VisualizationError: Error {
    case emptyInput
    case invalidEmotion(String)
    case textTooLong(Int)
    case serviceUnavailable(retryAfter: Int)
    case timeout
    case contentFiltered
    case networkError(Error)
    case unknown(String)

    var userMessage: String {
        switch self {
        case .emptyInput:
            return "Please enter how you're feeling or select some emotions"
        case .invalidEmotion(let emotion):
            return "Unknown emotion: \(emotion)"
        case .textTooLong(let length):
            return "Your text is too long (\(length) characters). Please shorten it."
        case .serviceUnavailable:
            return "Image generation is temporarily unavailable. Please try again."
        case .timeout:
            return "Taking too long to generate. Please try again."
        case .contentFiltered:
            return "Unable to visualize this input. Try different wording."
        case .networkError:
            return "Network error. Please check your connection."
        case .unknown(let message):
            return message
        }
    }

    var canRetry: Bool {
        switch self {
        case .serviceUnavailable, .timeout, .networkError:
            return true
        default:
            return false
        }
    }
}
```

### 7.2 Error Handling in ViewModel

```swift
class DrawMyFeelingsViewModel: ObservableObject {
    @Published var error: VisualizationError?
    @Published var isShowingError = false

    func generateVisualization() async {
        do {
            let response = try await apiService.generateVisualization(input: input)
            // Handle success
        } catch let error as VisualizationError {
            await MainActor.run {
                self.error = error
                self.isShowingError = true
            }
        } catch {
            await MainActor.run {
                self.error = .networkError(error)
                self.isShowingError = true
            }
        }
    }
}
```

## 8. Logging

### 8.1 Error Logging Format

```python
import structlog

logger = structlog.get_logger()

def log_error(error: VisualizationError, request_id: str):
    logger.error(
        "visualization_error",
        error_code=error.code.value,
        message=error.message,
        status_code=error.status_code,
        details=error.details,
        request_id=request_id
    )
```

### 8.2 Log Levels

| Level | Use Case |
|-------|----------|
| DEBUG | Prompt construction, API request details |
| INFO | Successful generation, timing metrics |
| WARNING | Validation errors, rate limits, retries |
| ERROR | Service errors, timeouts, unexpected failures |

## 9. Monitoring (Future)

Recommended metrics to track:

| Metric | Description |
|--------|-------------|
| `visualization_requests_total` | Total requests by status |
| `visualization_errors_total` | Errors by error code |
| `visualization_latency_seconds` | Generation time histogram |
| `gemini_api_errors_total` | Upstream API errors |
| `gemini_api_latency_seconds` | Upstream API latency |
