# Technology Stack Specification

## Document Information
- **Milestone**: 002-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-24
- **Version**: 1.0

## Technology Selection Overview

This document provides detailed justification for all technology choices in the backend system.

## Core Technologies

### Python 3.11+

**Selection Rationale**:
- ✅ Excellent ecosystem for API development
- ✅ Strong AI/ML library support (future-proof)
- ✅ High developer productivity
- ✅ Great async support (asyncio)
- ✅ Type hints for better code quality

**Version**: Python 3.11 or later
- Performance improvements over 3.10
- Better error messages
- Modern syntax features

### FastAPI

**Selection Rationale**:
- ✅ High performance (comparable to Node.js)
- ✅ Automatic API documentation (OpenAPI/Swagger)
- ✅ Built-in request/response validation (Pydantic)
- ✅ Async support out of the box
- ✅ Modern Python features (type hints)
- ✅ Easy to learn and use

**Alternative Considered**: Flask
- ❌ Flask is more traditional but lacks built-in async
- ❌ Requires more boilerplate for validation
- ❌ Manual API documentation setup

**Version**: FastAPI 0.104+

**Key Features to Use**:
```python
- Dependency injection
- Background tasks
- WebSocket support (future)
- Automatic data validation
- OAuth2 authentication
```

### PostgreSQL

**Selection Rationale**:
- ✅ Robust and reliable
- ✅ JSONB support for flexible schemas
- ✅ Excellent performance
- ✅ Strong consistency guarantees
- ✅ Rich ecosystem and tooling
- ✅ Great documentation

**Alternative Considered**: MySQL
- ❌ Less robust JSON support
- ❌ Limited advanced features

**Alternative Considered**: MongoDB
- ❌ NoSQL may be overkill
- ❌ Less structure for relational data

**Version**: PostgreSQL 15+

**Extensions to Enable**:
- `uuid-ossp`: UUID generation
- `pg_trgm`: Text search optimization

### SQLAlchemy ORM

**Selection Rationale**:
- ✅ Industry standard Python ORM
- ✅ Powerful query interface
- ✅ Excellent PostgreSQL support
- ✅ Migration support via Alembic
- ✅ Connection pooling
- ✅ Both Core and ORM APIs

**Version**: SQLAlchemy 2.0+

**Usage Pattern**:
```python
# Modern async ORM style
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine

engine = create_async_engine("postgresql+asyncpg://...")
async with AsyncSession(engine) as session:
    result = await session.execute(query)
```

### Pydantic

**Selection Rationale**:
- ✅ Built into FastAPI
- ✅ Runtime type checking
- ✅ Data validation
- ✅ JSON serialization
- ✅ Settings management

**Version**: Pydantic 2.0+

**Usage**:
- Request/response models
- Configuration management
- Data transformation

## Development & Infrastructure

### Docker

**Selection Rationale**:
- ✅ Consistent development environment
- ✅ Easy dependency management
- ✅ Isolation from host system
- ✅ Production parity
- ✅ Cross-platform compatibility

**Version**: Docker 24+

### Docker Compose

**Selection Rationale**:
- ✅ Multi-container orchestration
- ✅ Simple configuration (YAML)
- ✅ Perfect for local development
- ✅ Easy service networking
- ✅ Volume management

**Version**: Docker Compose 2.20+

**Services Defined**:
1. API server (Python/FastAPI)
2. PostgreSQL database
3. Adminer (optional DB UI)

### uvicorn

**Selection Rationale**:
- ✅ Lightning-fast ASGI server
- ✅ Recommended for FastAPI
- ✅ Async support
- ✅ Auto-reload for development
- ✅ Production-ready

**Version**: uvicorn 0.24+

**Development Configuration**:
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## External Service Clients

### Google Gemini API Client

**Library**: `google-generativeai`

**Selection Rationale**:
- ✅ Official Google SDK
- ✅ Well-maintained
- ✅ Comprehensive documentation
- ✅ Type hints support

**Version**: Latest stable

**Usage**:
```python
import google.generativeai as genai

genai.configure(api_key=os.environ["GEMINI_API_KEY"])
model = genai.GenerativeModel('gemini-1.5-pro')
response = model.generate_content(prompt)
```

### HTTP Client for Nano Banana Pro

**Library**: `httpx`

**Selection Rationale**:
- ✅ Modern async HTTP client
- ✅ Drop-in replacement for requests
- ✅ HTTP/2 support
- ✅ Connection pooling
- ✅ Timeout management

**Version**: httpx 0.25+

**Usage**:
```python
async with httpx.AsyncClient() as client:
    response = await client.post(
        "https://api.nanobanana.pro/visualize",
        json=data,
        headers={"Authorization": f"Bearer {api_key}"}
    )
```

## Testing & Quality

### pytest

**Selection Rationale**:
- ✅ Most popular Python testing framework
- ✅ Rich plugin ecosystem
- ✅ Fixtures for test setup
- ✅ Parametrized testing
- ✅ Great error messages

**Version**: pytest 7.4+

**Plugins**:
- `pytest-asyncio`: Async test support
- `pytest-cov`: Code coverage
- `pytest-mock`: Mocking utilities

### pytest-asyncio

**Selection Rationale**:
- ✅ Test async code easily
- ✅ Integrates with pytest
- ✅ Event loop management

### httpx (for testing)

**Selection Rationale**:
- ✅ Built-in FastAPI test client
- ✅ Async support
- ✅ No actual HTTP calls needed

**Usage**:
```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)
response = client.get("/api/health")
assert response.status_code == 200
```

## Code Quality Tools

### Ruff

**Selection Rationale**:
- ✅ Extremely fast linter (Rust-based)
- ✅ Replaces flake8, isort, pyupgrade
- ✅ Auto-fix capabilities
- ✅ Configurable

**Version**: ruff 0.1+

### Black

**Selection Rationale**:
- ✅ Opinionated code formatter
- ✅ Zero configuration
- ✅ Consistent style
- ✅ Fast

**Version**: black 23.0+

### mypy

**Selection Rationale**:
- ✅ Static type checker
- ✅ Catches type errors early
- ✅ IDE integration
- ✅ Gradual typing support

**Version**: mypy 1.7+

## Database Tools

### Alembic

**Selection Rationale**:
- ✅ Database migration tool
- ✅ Works with SQLAlchemy
- ✅ Version control for schema
- ✅ Auto-generate migrations
- ✅ Rollback support

**Version**: alembic 1.12+

### Adminer (Optional)

**Selection Rationale**:
- ✅ Lightweight database UI
- ✅ Single PHP file
- ✅ PostgreSQL support
- ✅ Good for development

**Alternative**: pgAdmin 4
- More features but heavier

## Environment & Configuration

### python-dotenv

**Selection Rationale**:
- ✅ Load environment variables from .env
- ✅ Simple and lightweight
- ✅ Standard in Python community

**Version**: python-dotenv 1.0+

### Pydantic Settings

**Selection Rationale**:
- ✅ Type-safe configuration
- ✅ Environment variable parsing
- ✅ Validation
- ✅ Built into Pydantic

**Usage**:
```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    gemini_api_key: str

    class Config:
        env_file = ".env"
```

## Security

### python-jose[cryptography]

**Selection Rationale**:
- ✅ JWT token generation/validation
- ✅ Cryptographic signing
- ✅ Industry standard

**Version**: python-jose 3.3+

### passlib[bcrypt]

**Selection Rationale**:
- ✅ Password hashing
- ✅ Multiple algorithm support
- ✅ Secure defaults

**Version**: passlib 1.7+

### python-multipart

**Selection Rationale**:
- ✅ Required for FastAPI form data
- ✅ File upload support

## Complete Dependency List

```toml
# pyproject.toml (using Poetry or pip)

[tool.poetry.dependencies]
python = "^3.11"
fastapi = "^0.104.0"
uvicorn = {extras = ["standard"], version = "^0.24.0"}
sqlalchemy = "^2.0.0"
asyncpg = "^0.29.0"  # PostgreSQL async driver
pydantic = "^2.5.0"
pydantic-settings = "^2.1.0"
python-dotenv = "^1.0.0"
python-jose = {extras = ["cryptography"], version = "^3.3.0"}
passlib = {extras = ["bcrypt"], version = "^1.7.4"}
python-multipart = "^0.0.6"
httpx = "^0.25.0"
google-generativeai = "^0.3.0"
alembic = "^1.12.0"

[tool.poetry.group.dev.dependencies]
pytest = "^7.4.0"
pytest-asyncio = "^0.21.0"
pytest-cov = "^4.1.0"
pytest-mock = "^3.12.0"
ruff = "^0.1.0"
black = "^23.0.0"
mypy = "^1.7.0"
```

## Technology Matrix Summary

| Category | Technology | Version | Purpose |
|----------|-----------|---------|---------|
| Runtime | Python | 3.11+ | Language |
| Framework | FastAPI | 0.104+ | Web API |
| Server | uvicorn | 0.24+ | ASGI server |
| Database | PostgreSQL | 15+ | Data store |
| ORM | SQLAlchemy | 2.0+ | Database access |
| Validation | Pydantic | 2.0+ | Data validation |
| Migration | Alembic | 1.12+ | Schema migrations |
| HTTP Client | httpx | 0.25+ | External APIs |
| AI Client | google-generativeai | Latest | Gemini integration |
| Testing | pytest | 7.4+ | Test framework |
| Linting | Ruff | 0.1+ | Code linting |
| Formatting | Black | 23.0+ | Code formatting |
| Type Check | mypy | 1.7+ | Static typing |
| Auth | python-jose | 3.3+ | JWT tokens |
| Password | passlib | 1.7+ | Hashing |
| Container | Docker | 24+ | Containerization |
| Orchestration | Docker Compose | 2.20+ | Multi-container |

## Development Tools

### IDE Recommendations

1. **VS Code** (Recommended)
   - Python extension
   - Pylance (type checking)
   - Docker extension
   - REST Client extension

2. **PyCharm Professional**
   - Full-featured IDE
   - Excellent debugging
   - Database tools built-in

### Useful Extensions

- **Pre-commit hooks**: Auto-format and lint before commits
- **GitHub Copilot**: AI code completion
- **Thunder Client/Postman**: API testing

## Performance Considerations

### Expected Performance

- **Request Latency**: < 100ms for simple queries
- **Database Queries**: < 50ms for indexed lookups
- **External API Calls**: 1-3s (depends on Gemini/NanaBanana)
- **Concurrent Requests**: 100+ (with async)

### Optimization Strategies

1. **Database**: Connection pooling, indexed queries
2. **API**: Async operations, caching headers
3. **External Services**: Timeout management, circuit breakers

## Next Steps

1. Review technology choices with team
2. Set up development environment (see `04-docker-infrastructure.md`)
3. Initialize project structure
4. Install dependencies
5. Begin implementation
