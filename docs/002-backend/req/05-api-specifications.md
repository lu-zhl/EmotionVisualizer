# API Specifications

## Document Information
- **Milestone**: 002-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-24
- **Version**: 1.0

## Overview

This document specifies all REST API endpoints for the EmotionVisualizer backend. The API follows RESTful conventions and uses JSON for request/response payloads.

**Base URL**: `http://localhost:8000/api/v1`

**Authentication**: Bearer token (JWT) in Authorization header

## API Design Principles

1. **RESTful**: Standard HTTP methods and status codes
2. **Versioned**: `/api/v1/` prefix for all endpoints
3. **Consistent**: Uniform response format
4. **Documented**: OpenAPI/Swagger auto-generated docs at `/docs`
5. **Secure**: Authentication required for user-specific data

## Standard Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2025-11-24T12:00:00Z"
  }
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      // Additional context
    }
  },
  "meta": {
    "timestamp": "2025-11-24T12:00:00Z"
  }
}
```

## Authentication Endpoints

### POST /api/v1/auth/register

Register a new user account.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!",
  "name": "John Doe"
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe",
      "created_at": "2025-11-24T12:00:00Z"
    },
    "access_token": "eyJ...",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

**Errors**:
- `400`: Invalid input (weak password, invalid email)
- `409`: Email already registered

### POST /api/v1/auth/login

Authenticate and receive access token.

**Request**:
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "token_type": "bearer",
    "expires_in": 3600,
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "name": "John Doe"
    }
  }
}
```

**Errors**:
- `401`: Invalid credentials
- `400`: Missing required fields

### POST /api/v1/auth/refresh

Refresh access token.

**Headers**:
```
Authorization: Bearer <current_token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "access_token": "eyJ...",
    "token_type": "bearer",
    "expires_in": 3600
  }
}
```

### GET /api/v1/auth/me

Get current user info.

**Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "name": "John Doe",
    "created_at": "2025-11-24T12:00:00Z",
    "entry_count": 15,
    "visualization_count": 8
  }
}
```

## Emotion Entry Endpoints

### GET /api/v1/entries

List all emotion entries for authenticated user.

**Headers**:
```
Authorization: Bearer <token>
```

**Query Parameters**:
- `limit` (optional): Number of entries (default: 50, max: 100)
- `offset` (optional): Pagination offset (default: 0)
- `sort` (optional): Sort field (default: `-created_at`)

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "entries": [
      {
        "id": "uuid",
        "situation": "Morning presentation at work",
        "emotions": ["anxiety", "excitement"],
        "intensity": 0.7,
        "notes": "Big presentation coming up",
        "created_at": "2025-11-23T10:00:00Z",
        "updated_at": "2025-11-23T10:00:00Z",
        "has_visualization": true
      }
    ],
    "total": 15,
    "limit": 50,
    "offset": 0
  }
}
```

### POST /api/v1/entries

Create a new emotion entry.

**Headers**:
```
Authorization: Bearer <token>
```

**Request**:
```json
{
  "situation": "Morning presentation at work",
  "emotions": ["anxiety", "excitement"],
  "intensity": 0.7,
  "notes": "Big presentation coming up"
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "entry": {
      "id": "uuid",
      "situation": "Morning presentation at work",
      "emotions": ["anxiety", "excitement"],
      "intensity": 0.7,
      "notes": "Big presentation coming up",
      "created_at": "2025-11-24T12:00:00Z",
      "updated_at": "2025-11-24T12:00:00Z",
      "has_visualization": false
    }
  }
}
```

**Errors**:
- `400`: Invalid input (intensity not 0-1, invalid emotions)
- `401`: Unauthorized

### GET /api/v1/entries/{entry_id}

Get a specific emotion entry.

**Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "situation": "Morning presentation at work",
    "emotions": ["anxiety", "excitement"],
    "intensity": 0.7,
    "notes": "Big presentation coming up",
    "created_at": "2025-11-23T10:00:00Z",
    "updated_at": "2025-11-23T10:00:00Z",
    "has_visualization": true,
    "visualization_id": "uuid"
  }
}
```

**Errors**:
- `404`: Entry not found
- `403`: Entry belongs to different user

### PUT /api/v1/entries/{entry_id}

Update an emotion entry.

**Headers**:
```
Authorization: Bearer <token>
```

**Request**:
```json
{
  "situation": "Updated situation",
  "emotions": ["anxiety", "excitement", "joy"],
  "intensity": 0.8,
  "notes": "Updated notes"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "situation": "Updated situation",
    "emotions": ["anxiety", "excitement", "joy"],
    "intensity": 0.8,
    "notes": "Updated notes",
    "created_at": "2025-11-23T10:00:00Z",
    "updated_at": "2025-11-24T12:00:00Z"
  }
}
```

### DELETE /api/v1/entries/{entry_id}

Delete an emotion entry.

**Headers**:
```
Authorization: Bearer <token>
```

**Response** (204 No Content)

**Errors**:
- `404`: Entry not found
- `403`: Entry belongs to different user

## Dynamic Intake Endpoints (Gemini Integration)

### POST /api/v1/intake/analyze

Start dynamic intake flow - analyze situation and generate follow-up scenarios.

**Headers**:
```
Authorization: Bearer <token>
```

**Request**:
```json
{
  "situation": "I'm feeling overwhelmed at work"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "session_id": "uuid",
    "scenarios": [
      {
        "id": "scenario-1",
        "question": "Is your workload manageable but you're struggling with specific tasks?",
        "options": [
          {
            "id": "opt-1a",
            "text": "Yes, I'm stuck on difficult problems",
            "emotion_indicators": ["frustration", "anxiety"]
          },
          {
            "id": "opt-1b",
            "text": "No, I have too many things to do",
            "emotion_indicators": ["stress", "overwhelm"]
          },
          {
            "id": "opt-1c",
            "text": "It's more about the pace and pressure",
            "emotion_indicators": ["anxiety", "exhaustion"]
          }
        ]
      }
    ],
    "ai_context": "Analyzing work-related stress patterns"
  }
}
```

**Errors**:
- `400`: Empty or invalid situation
- `503`: Gemini API unavailable

### POST /api/v1/intake/refine

Continue intake flow with user's selection.

**Headers**:
```
Authorization: Bearer <token>
```

**Request**:
```json
{
  "session_id": "uuid",
  "selected_option_id": "opt-1a",
  "additional_context": "Working on a complex backend project"
}
```

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "session_id": "uuid",
    "is_complete": false,
    "scenarios": [
      {
        "id": "scenario-2",
        "question": "What aspect of the backend project is most challenging?",
        "options": [
          {
            "id": "opt-2a",
            "text": "Architecture and design decisions",
            "emotion_indicators": ["uncertainty", "pressure"]
          },
          {
            "id": "opt-2b",
            "text": "Technical implementation",
            "emotion_indicators": ["frustration", "determination"]
          },
          {
            "id": "opt-2c",
            "text": "Timeline and deadlines",
            "emotion_indicators": ["anxiety", "stress"]
          }
        ]
      }
    ]
  }
}
```

### POST /api/v1/intake/complete

Finalize intake flow and create entry with AI summary.

**Headers**:
```
Authorization: Bearer <token>
```

**Request**:
```json
{
  "session_id": "uuid",
  "final_emotions": ["anxiety", "frustration", "determination"],
  "intensity": 0.75
}
```

**Response** (201 Created):
```json
{
  "success": true,
  "data": {
    "entry": {
      "id": "uuid",
      "situation": "AI-generated summary based on intake flow",
      "emotions": ["anxiety", "frustration", "determination"],
      "intensity": 0.75,
      "notes": "Generated from dynamic intake session",
      "created_at": "2025-11-24T12:00:00Z"
    },
    "ai_summary": "You're experiencing work-related stress primarily due to technical challenges in a backend project. The complexity of architecture decisions combined with implementation difficulties is creating feelings of frustration and anxiety, though you're maintaining determination to overcome these obstacles.",
    "insights": [
      "Technical challenges are your primary stressor",
      "You're balancing multiple complex decisions",
      "Your determination indicates strong problem-solving motivation"
    ]
  }
}
```

## Visualization Endpoints

### POST /api/v1/visualizations

Generate visualization for an emotion entry.

**Headers**:
```
Authorization: Bearer <token>
```

**Request**:
```json
{
  "entry_id": "uuid",
  "style": "abstract"  // Options: abstract, diagram, metaphor
}
```

**Response** (202 Accepted):
```json
{
  "success": true,
  "data": {
    "visualization_id": "uuid",
    "status": "processing",
    "estimated_time_seconds": 15,
    "polling_url": "/api/v1/visualizations/uuid"
  }
}
```

**Errors**:
- `404`: Entry not found
- `503`: Visualization service unavailable

### GET /api/v1/visualizations/{visualization_id}

Get visualization status and result.

**Headers**:
```
Authorization: Bearer <token>
```

**Response** (200 OK - Completed):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "entry_id": "uuid",
    "status": "completed",
    "image_url": "https://storage.example.com/visualizations/uuid.png",
    "thumbnail_url": "https://storage.example.com/visualizations/uuid_thumb.png",
    "summary": "Your emotional state reflects a complex mix of anticipation and concern centered around professional challenges.",
    "insights": [
      "High energy emotions present (excitement, anxiety)",
      "Performance-related stress patterns detected",
      "Multiple conflicting feelings indicate complex situation"
    ],
    "visual_elements": [
      {
        "type": "color_palette",
        "values": ["#FF6B6B", "#4ECDC4", "#FFE66D"]
      },
      {
        "type": "shape",
        "description": "Intertwining spirals representing conflicting emotions"
      }
    ],
    "created_at": "2025-11-24T12:00:00Z",
    "completed_at": "2025-11-24T12:00:15Z"
  }
}
```

**Response** (200 OK - Processing):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "processing",
    "progress": 65,
    "estimated_time_remaining_seconds": 5
  }
}
```

**Response** (200 OK - Failed):
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "status": "failed",
    "error_message": "Visualization generation failed",
    "retry_allowed": true
  }
}
```

### GET /api/v1/visualizations

List all visualizations for authenticated user.

**Headers**:
```
Authorization: Bearer <token>
```

**Query Parameters**:
- `limit` (optional): Number of visualizations (default: 20)
- `offset` (optional): Pagination offset (default: 0)

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "visualizations": [
      {
        "id": "uuid",
        "entry_id": "uuid",
        "status": "completed",
        "image_url": "https://...",
        "thumbnail_url": "https://...",
        "created_at": "2025-11-24T12:00:00Z"
      }
    ],
    "total": 8,
    "limit": 20,
    "offset": 0
  }
}
```

### DELETE /api/v1/visualizations/{visualization_id}

Delete a visualization.

**Headers**:
```
Authorization: Bearer <token>
```

**Response** (204 No Content)

## Analytics Endpoints

### GET /api/v1/analytics/summary

Get user's emotion analytics summary.

**Headers**:
```
Authorization: Bearer <token>
```

**Query Parameters**:
- `period` (optional): time period (7d, 30d, 90d, all) (default: 30d)

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "period": "30d",
    "total_entries": 15,
    "total_visualizations": 8,
    "most_common_emotions": [
      {"emotion": "anxiety", "count": 12, "percentage": 35.3},
      {"emotion": "excitement", "count": 8, "percentage": 23.5},
      {"emotion": "frustration", "count": 7, "percentage": 20.6}
    ],
    "average_intensity": 0.68,
    "intensity_trend": "stable",  // increasing, decreasing, stable
    "patterns": [
      "Work-related stress appears frequently",
      "Anxiety often paired with excitement",
      "Intensity peaks mid-week"
    ]
  }
}
```

### GET /api/v1/analytics/emotions/timeline

Get emotion frequency over time.

**Headers**:
```
Authorization: Bearer <token>
```

**Query Parameters**:
- `period` (optional): 7d, 30d, 90d (default: 30d)
- `granularity` (optional): day, week, month (default: day)

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "timeline": [
      {
        "date": "2025-11-18",
        "emotions": {
          "anxiety": 3,
          "excitement": 2,
          "joy": 1
        },
        "avg_intensity": 0.65
      },
      {
        "date": "2025-11-19",
        "emotions": {
          "anxiety": 2,
          "frustration": 1
        },
        "avg_intensity": 0.72
      }
    ]
  }
}
```

## Health & Utility Endpoints

### GET /health

System health check (no auth required).

**Response** (200 OK):
```json
{
  "status": "healthy",
  "timestamp": "2025-11-24T12:00:00Z",
  "version": "1.0.0"
}
```

### GET /health/ready

Readiness check including dependencies.

**Response** (200 OK):
```json
{
  "status": "ready",
  "checks": {
    "database": "healthy",
    "gemini_api": "healthy",
    "nanobanana_api": "healthy"
  },
  "timestamp": "2025-11-24T12:00:00Z"
}
```

### GET /api/v1/emotions

Get list of supported emotions.

**Response** (200 OK):
```json
{
  "success": true,
  "data": {
    "emotions": [
      {
        "id": "joy",
        "name": "Joy",
        "description": "Feeling happy and pleased",
        "color": "#FFD700",
        "icon": "smile"
      },
      {
        "id": "anxiety",
        "name": "Anxiety",
        "description": "Feeling worried or uneasy",
        "color": "#808080",
        "icon": "cloud"
      }
      // ... more emotions
    ]
  }
}
```

## Rate Limiting

All authenticated endpoints are rate-limited:

**Limits**:
- `100 requests per minute` per user
- `1000 requests per hour` per user
- `10 concurrent visualization requests` per user

**Headers**:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1700000000
```

**Error Response** (429 Too Many Requests):
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMIT_EXCEEDED",
    "message": "Too many requests. Please wait before trying again.",
    "details": {
      "retry_after_seconds": 30
    }
  }
}
```

## WebSocket API (Future Enhancement)

### WS /api/v1/ws/visualizations/{visualization_id}

Real-time visualization progress updates.

**Connection**:
```javascript
ws://localhost:8000/api/v1/ws/visualizations/uuid?token=<jwt_token>
```

**Messages**:
```json
{
  "type": "progress",
  "data": {
    "progress": 45,
    "status": "generating",
    "message": "Creating visual elements..."
  }
}
```

```json
{
  "type": "complete",
  "data": {
    "visualization_id": "uuid",
    "image_url": "https://..."
  }
}
```

## Error Codes Reference

| Code | HTTP Status | Description |
|------|-------------|-------------|
| VALIDATION_ERROR | 400 | Invalid request data |
| UNAUTHORIZED | 401 | Missing or invalid token |
| FORBIDDEN | 403 | Insufficient permissions |
| NOT_FOUND | 404 | Resource not found |
| CONFLICT | 409 | Resource already exists |
| RATE_LIMIT_EXCEEDED | 429 | Too many requests |
| INTERNAL_ERROR | 500 | Server error |
| SERVICE_UNAVAILABLE | 503 | External service down |
| GEMINI_API_ERROR | 503 | Gemini API failure |
| VISUALIZATION_ERROR | 503 | NanaBanana API failure |

## OpenAPI Documentation

Once the backend is running, interactive API documentation is available at:

- **Swagger UI**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`
- **OpenAPI JSON**: `http://localhost:8000/openapi.json`

## Testing with curl Examples

```bash
# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!","name":"Test User"}'

# Login
curl -X POST http://localhost:8000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","password":"Test123!"}'

# Create entry (with token)
curl -X POST http://localhost:8000/api/v1/entries \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"situation":"Test","emotions":["joy"],"intensity":0.8}'

# Get entries
curl -X GET http://localhost:8000/api/v1/entries \
  -H "Authorization: Bearer <token>"
```

## Next Steps

1. Review API specifications with iOS team
2. Implement API endpoints based on this specification
3. Add comprehensive API tests
4. Generate OpenAPI documentation
5. Create Postman collection for manual testing
