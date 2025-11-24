# Backend System Architecture

## Document Information
- **Milestone**: 002-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-24
- **Version**: 1.0

## Architecture Overview

The EmotionVisualizer backend follows a **layered architecture** pattern, providing clear separation of concerns and maintainability.

```
┌─────────────────────────────────────────────────────────────┐
│                      iOS Client (SwiftUI)                   │
└─────────────────────────┬───────────────────────────────────┘
                          │ HTTPS/JSON
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                    API Gateway Layer                        │
│  (FastAPI / Flask - Request Routing & Validation)          │
└─────────────────────────┬───────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────────┐
│                   Business Logic Layer                      │
│         (Services: Emotion Analysis, Visualization)         │
└─────────┬───────────────┬───────────────────────────────────┘
          │               │
          ▼               ▼
┌──────────────┐   ┌──────────────────────────────┐
│  External    │   │   Data Access Layer (DAL)    │
│  Services    │   │   (ORM - SQLAlchemy)         │
│              │   └──────────────┬───────────────┘
│ - Gemini     │                  │
│ - NanaBanana │                  ▼
└──────────────┘   ┌──────────────────────────────┐
                   │   Database (PostgreSQL)      │
                   │   - Users                    │
                   │   - Emotions                 │
                   │   - Visualizations           │
                   └──────────────────────────────┘
```

## Component Design

### 1. API Gateway Layer

**Responsibility**: Handle HTTP requests, routing, validation, authentication

**Technologies**:
- FastAPI (preferred) or Flask
- Pydantic for request/response validation
- JWT for authentication
- CORS middleware for iOS app

**Key Features**:
- RESTful endpoint routing
- Request/response validation
- Authentication and authorization
- Rate limiting
- Error handling and responses
- API documentation (OpenAPI/Swagger)

### 2. Business Logic Layer

**Responsibility**: Core application logic, orchestration of services

**Components**:

#### EmotionAnalysisService
- Processes user input
- Generates follow-up scenarios via Gemini API
- Analyzes emotion patterns
- Creates insights and summaries

#### VisualizationService
- Prepares visualization requests
- Calls Nano Banana Pro API
- Handles visualization metadata
- Manages asset storage/retrieval

#### UserService
- User management
- Authentication logic
- Profile handling

**Design Patterns**:
- Service layer pattern
- Dependency injection
- Strategy pattern (for different AI providers)

### 3. Data Access Layer

**Responsibility**: Database operations, data persistence

**Technologies**:
- SQLAlchemy ORM
- Alembic for migrations
- Connection pooling

**Features**:
- CRUD operations for all entities
- Query optimization
- Transaction management
- Database migrations

### 4. External Services Integration

**Gemini API Integration**:
```python
class GeminiClient:
    - generate_scenarios(situation: str) -> List[Scenario]
    - analyze_emotions(entry: EmotionEntry) -> Analysis
    - generate_summary(context: dict) -> str
```

**Nano Banana Pro Integration**:
```python
class NanaBananaClient:
    - generate_visualization(data: dict) -> VisualizationResponse
    - get_visualization_status(id: str) -> Status
```

## Data Flow

### Scenario 1: Create New Emotion Entry

```
iOS App → POST /api/entries
    ↓
API Gateway validates request
    ↓
EmotionAnalysisService.create_entry()
    ↓
Store in database via DAL
    ↓
Call Gemini API for initial analysis
    ↓
Return entry + scenarios to iOS
```

### Scenario 2: Generate Visualization

```
iOS App → POST /api/visualizations
    ↓
API Gateway validates request
    ↓
VisualizationService.generate()
    ↓
Retrieve entry from database
    ↓
Call Gemini for detailed analysis
    ↓
Call NanaBanana with analysis data
    ↓
Store visualization metadata in DB
    ↓
Return visualization URL to iOS
```

## Security Architecture

### Authentication Flow

```
iOS App → POST /api/auth/login (email, password)
    ↓
UserService validates credentials
    ↓
Generate JWT token
    ↓
Return token to iOS
    ↓
iOS includes token in Authorization header for subsequent requests
```

### Security Layers

1. **API Keys**: Stored in environment variables, never exposed to client
2. **JWT Tokens**: Short-lived, signed tokens for user sessions
3. **HTTPS**: All communication encrypted (production)
4. **Input Validation**: Pydantic models prevent injection attacks
5. **Rate Limiting**: Prevent abuse of API endpoints

## Scalability Considerations

### Current (Local Development)

- Single container for API server
- Single PostgreSQL instance
- Synchronous request handling

### Future Enhancements (Out of Scope for 002-backend)

- Horizontal scaling with load balancer
- Async task queue (Celery) for long-running operations
- Redis caching layer
- CDN for visualization assets
- Database read replicas

## Error Handling Strategy

### Error Categories

1. **Client Errors (4xx)**:
   - 400 Bad Request: Invalid input
   - 401 Unauthorized: Missing/invalid token
   - 404 Not Found: Resource doesn't exist
   - 429 Too Many Requests: Rate limit exceeded

2. **Server Errors (5xx)**:
   - 500 Internal Server Error: Unhandled exceptions
   - 502 Bad Gateway: External service failure
   - 503 Service Unavailable: System overload

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_INPUT",
    "message": "Emotion intensity must be between 0 and 1",
    "details": {
      "field": "intensity",
      "value": 1.5
    }
  }
}
```

## Monitoring and Observability

### Logging Strategy

- **Structured logging** (JSON format)
- **Log levels**: DEBUG, INFO, WARNING, ERROR, CRITICAL
- **Log to**: Console (Docker logs), optionally file

### Metrics to Track

- Request count per endpoint
- Response time (p50, p95, p99)
- Error rate
- External API latency
- Database query performance

### Health Checks

```
GET /health
GET /health/ready (includes DB check)
```

## Configuration Management

### Environment-Based Config

```python
# config.py
class Settings:
    # App
    APP_NAME: str = "EmotionVisualizer"
    DEBUG: bool = True

    # Database
    DATABASE_URL: str

    # External APIs
    GEMINI_API_KEY: str
    NANOBANANA_API_KEY: str

    # Security
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60
```

### Configuration Sources

1. Environment variables (`.env` file)
2. Docker Compose environment section
3. Default values in code

## Technology Decisions

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Web Framework | FastAPI | Modern, fast, async support, auto-docs |
| ORM | SQLAlchemy | Industry standard, flexible, well-documented |
| Database | PostgreSQL | Reliable, JSON support, good for relational data |
| Validation | Pydantic | Built into FastAPI, type-safe |
| Migration | Alembic | Standard with SQLAlchemy |
| Testing | pytest | Most popular Python testing framework |

## Deployment Architecture (Local Dev)

```yaml
services:
  api:
    - Python backend
    - Port 8000
    - Volume mount: ./backend → /app
    - Hot reload enabled

  db:
    - PostgreSQL 15
    - Port 5432
    - Volume mount: ./data/postgres → /var/lib/postgresql/data

  adminer (optional):
    - Database management UI
    - Port 8080
```

## API Versioning Strategy

- **URL versioning**: `/api/v1/...`
- Current version: v1
- Breaking changes require new version
- Maintain backward compatibility for 1 major version

## Next Steps

1. Review and approve architecture
2. Begin detailed API specification (see `05-api-specifications.md`)
3. Design database schema (see `06-database-design.md`)
4. Implement Docker infrastructure (see `04-docker-infrastructure.md`)
