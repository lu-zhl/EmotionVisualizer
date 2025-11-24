# Development Workflow Guidelines

## Document Information
- **Milestone**: 002-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-24
- **Version**: 1.0

## Overview

This document provides comprehensive guidelines for developers working on the EmotionVisualizer backend. It covers setup, daily workflow, testing, code quality, and collaboration practices.

## Initial Project Setup

### Prerequisites

**Required**:
- Docker Desktop 24+ (includes Docker Compose)
- Git
- Code editor (VS Code recommended)
- Postman or Thunder Client (for API testing)

**Optional**:
- Python 3.11+ (for local development without Docker)
- PostgreSQL client (psql)
- pgAdmin or DBeaver (database GUI)

### Project Initialization

```bash
# 1. Clone repository
git clone git@github.com:lu-zhl/EmotionVisualizer.git
cd EmotionVisualizer

# 2. Create backend directory structure
mkdir -p backend/app/{api,models,schemas,services,core,db}
mkdir -p backend/tests
mkdir -p data/{postgres,logs}

# 3. Copy environment template
cp backend/.env.example backend/.env

# 4. Edit .env file with your API keys
# Required:
# - GEMINI_API_KEY (get from Google AI Studio)
# - NANOBANANA_API_KEY (get from Nano Banana Pro)
nano backend/.env  # or use your preferred editor

# 5. Start Docker containers
docker-compose up -d

# 6. Wait for services to be ready (check health)
docker-compose ps

# 7. Run database migrations
docker-compose exec api alembic upgrade head

# 8. (Optional) Seed development data
docker-compose exec api python -m app.seeds.dev_data

# 9. Verify API is running
curl http://localhost:8000/health
```

### Directory Structure Setup

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                    # FastAPI app entry point
│   ├── api/                       # API routes
│   │   ├── __init__.py
│   │   ├── deps.py                # Dependencies (auth, db session)
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── auth.py
│   │       ├── entries.py
│   │       ├── visualizations.py
│   │       └── intake.py
│   ├── core/                      # Core config and utilities
│   │   ├── __init__.py
│   │   ├── config.py              # Settings management
│   │   ├── security.py            # JWT, password hashing
│   │   └── logging.py             # Logging configuration
│   ├── db/                        # Database setup
│   │   ├── __init__.py
│   │   ├── session.py             # Async session management
│   │   └── base.py                # SQLAlchemy base
│   ├── models/                    # SQLAlchemy models
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── emotion_entry.py
│   │   ├── visualization.py
│   │   └── intake_session.py
│   ├── schemas/                   # Pydantic schemas
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── emotion_entry.py
│   │   ├── visualization.py
│   │   └── token.py
│   ├── services/                  # Business logic
│   │   ├── __init__.py
│   │   ├── auth_service.py
│   │   ├── emotion_service.py
│   │   ├── visualization_service.py
│   │   ├── gemini_client.py
│   │   └── nanobanana_client.py
│   └── seeds/                     # Database seeders
│       ├── __init__.py
│       └── dev_data.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py                # Pytest configuration
│   ├── test_api/
│   ├── test_services/
│   └── test_models/
├── alembic/                       # Database migrations
│   ├── versions/
│   ├── env.py
│   └── script.py.mako
├── Dockerfile
├── requirements.txt
├── pyproject.toml
├── alembic.ini
├── .env.example
└── .gitignore
```

## Daily Development Workflow

### Starting Work

```bash
# 1. Pull latest changes
git pull origin main

# 2. Start Docker containers
docker-compose up -d

# 3. Check container status
docker-compose ps

# 4. View API logs (in separate terminal)
docker-compose logs -f api

# 5. Check for pending migrations
docker-compose exec api alembic current
docker-compose exec api alembic heads

# 6. Apply any new migrations
docker-compose exec api alembic upgrade head
```

### Making Code Changes

**Hot Reload is Enabled**: Changes to Python files automatically restart the API server.

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make code changes in backend/app/
# Files are mounted as volumes, changes reflect immediately

# 3. Watch logs for errors
docker-compose logs -f api

# 4. Test your changes via API
curl http://localhost:8000/api/v1/your-endpoint

# 5. Run automated tests
docker-compose exec api pytest

# 6. Check code quality
docker-compose exec api ruff check .
docker-compose exec api black --check .
```

### Adding Dependencies

```bash
# 1. Add package to requirements.txt
echo "new-package==1.0.0" >> backend/requirements.txt

# 2. Rebuild API container
docker-compose build api

# 3. Restart container
docker-compose up -d api

# 4. Verify installation
docker-compose exec api pip list | grep new-package
```

### Database Changes

#### Creating Migrations

```bash
# 1. Modify SQLAlchemy models in backend/app/models/

# 2. Generate migration
docker-compose exec api alembic revision --autogenerate -m "description"

# 3. Review generated migration in alembic/versions/

# 4. Edit if needed (autogenerate isn't perfect)

# 5. Apply migration
docker-compose exec api alembic upgrade head

# 6. Test rollback
docker-compose exec api alembic downgrade -1
docker-compose exec api alembic upgrade head
```

#### Manual Migrations

```bash
# Create empty migration
docker-compose exec api alembic revision -m "description"

# Edit generated file with custom SQL/operations
# Then apply
docker-compose exec api alembic upgrade head
```

### Testing Workflow

#### Running Tests

```bash
# Run all tests
docker-compose exec api pytest

# Run specific test file
docker-compose exec api pytest tests/test_api/test_entries.py

# Run specific test
docker-compose exec api pytest tests/test_api/test_entries.py::test_create_entry

# Run with coverage
docker-compose exec api pytest --cov=app --cov-report=html

# View coverage report
open backend/htmlcov/index.html
```

#### Writing Tests

**Test Structure**:
```python
# tests/test_api/test_entries.py
import pytest
from httpx import AsyncClient
from app.main import app

@pytest.mark.asyncio
async def test_create_entry(client: AsyncClient, auth_headers: dict):
    """Test creating an emotion entry."""
    response = await client.post(
        "/api/v1/entries",
        json={
            "situation": "Test situation",
            "emotions": ["joy"],
            "intensity": 0.8
        },
        headers=auth_headers
    )
    assert response.status_code == 201
    data = response.json()
    assert data["success"] is True
    assert "entry" in data["data"]
```

**Fixtures** (`tests/conftest.py`):
```python
import pytest
from httpx import AsyncClient
from app.main import app
from app.core.config import settings

@pytest.fixture
async def client():
    async with AsyncClient(app=app, base_url="http://test") as ac:
        yield ac

@pytest.fixture
async def test_user(db_session):
    user = User(email="test@example.com", ...)
    db_session.add(user)
    await db_session.commit()
    return user

@pytest.fixture
async def auth_headers(test_user):
    token = create_access_token(test_user.id)
    return {"Authorization": f"Bearer {token}"}
```

### Code Quality

#### Linting

```bash
# Run Ruff linter
docker-compose exec api ruff check .

# Fix auto-fixable issues
docker-compose exec api ruff check . --fix

# Check specific file
docker-compose exec api ruff check app/api/v1/entries.py
```

#### Formatting

```bash
# Check formatting
docker-compose exec api black --check .

# Format code
docker-compose exec api black .

# Format specific file
docker-compose exec api black app/api/v1/entries.py
```

#### Type Checking

```bash
# Run mypy
docker-compose exec api mypy app

# Check specific file
docker-compose exec api mypy app/services/emotion_service.py
```

### API Testing

#### Using curl

```bash
# Register user
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "name": "Test User"
  }'

# Save token
TOKEN="eyJ..."

# Create entry
curl -X POST http://localhost:8000/api/v1/entries \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "situation": "Test situation",
    "emotions": ["joy"],
    "intensity": 0.8
  }'

# Get entries
curl -X GET http://localhost:8000/api/v1/entries \
  -H "Authorization: Bearer $TOKEN"
```

#### Using Swagger UI

1. Open http://localhost:8000/docs
2. Click "Authorize" button
3. Enter: `Bearer <your_token>`
4. Test endpoints interactively

### Debugging

#### Viewing Logs

```bash
# API logs
docker-compose logs -f api

# Last 100 lines
docker-compose logs --tail=100 api

# Database logs
docker-compose logs -f db

# All services
docker-compose logs -f
```

#### Interactive Debugging

```bash
# Access API container shell
docker-compose exec api bash

# Python shell with app context
docker-compose exec api python
>>> from app.main import app
>>> from app.db.session import SessionLocal
>>> # Test code here

# IPython shell
docker-compose exec api ipython
```

#### Database Debugging

```bash
# psql shell
docker-compose exec db psql -U emotionviz -d emotionviz_db

# Example queries
SELECT * FROM users;
SELECT * FROM emotion_entries WHERE user_id = 'uuid';

# Or use Adminer
# Start with: docker-compose --profile tools up -d
# Open: http://localhost:8080
```

### Environment Management

#### Environment Variables

**Development** (`.env`):
```bash
# Database
POSTGRES_USER=emotionviz
POSTGRES_PASSWORD=devpassword
POSTGRES_DB=emotionviz_db

# API
DEBUG=true
LOG_LEVEL=info

# External APIs
GEMINI_API_KEY=your-key-here
NANOBANANA_API_KEY=your-key-here

# Security
JWT_SECRET_KEY=dev-secret-change-in-production
```

**Production** (example - not in scope):
```bash
# Use strong passwords
# Store in secure secrets manager
# Enable all security features
```

## Git Workflow

### Branch Strategy

```
main
  ├── feature/add-intake-flow
  ├── feature/gemini-integration
  ├── bugfix/fix-auth-issue
  └── docs/update-api-specs
```

**Branch Naming**:
- `feature/description` - New features
- `bugfix/description` - Bug fixes
- `refactor/description` - Code refactoring
- `docs/description` - Documentation updates

### Commit Messages

**Format**:
```
<type>: <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance

**Examples**:
```bash
git commit -m "feat: add emotion entry creation endpoint"

git commit -m "fix: validate emotion intensity range

- Add check for 0-1 range
- Return 400 error for invalid values
- Add unit tests"

git commit -m "docs: update API specifications

- Add intake flow endpoints
- Document error codes
- Add curl examples"
```

### Pull Request Process

1. **Create PR** from feature branch to main
2. **Description**: Explain changes, link to requirements
3. **Tests**: Ensure all tests pass
4. **Code Quality**: Ruff and Black checks pass
5. **Review**: Request review from team
6. **Merge**: Squash and merge when approved

## Collaboration

### Code Review Guidelines

**For Authors**:
- Keep PRs focused and small
- Write clear descriptions
- Add tests for new features
- Update documentation
- Respond to feedback promptly

**For Reviewers**:
- Check logic and correctness
- Verify tests exist and pass
- Look for security issues
- Suggest improvements
- Be constructive and kind

### Communication

**When to Ask for Help**:
- Stuck on implementation for > 30 minutes
- Unclear requirements
- Breaking changes needed
- External service issues

**Where to Ask**:
- GitHub Issues for bugs/features
- PR comments for code questions
- Team chat for quick questions

## Troubleshooting

### Container Issues

**Container won't start**:
```bash
# Check logs
docker-compose logs api

# Rebuild
docker-compose build --no-cache api
docker-compose up -d api

# Remove and recreate
docker-compose down
docker-compose up -d
```

**Port conflicts**:
```bash
# Change ports in docker-compose.yml or .env
API_PORT=8001
POSTGRES_PORT=5433
```

### Database Issues

**Migrations fail**:
```bash
# Check current version
docker-compose exec api alembic current

# Manually fix database
docker-compose exec db psql -U emotionviz -d emotionviz_db

# Force revision
docker-compose exec api alembic stamp head
```

**Data corruption**:
```bash
# Nuclear option: reset database
docker-compose down
rm -rf data/postgres/*
docker-compose up -d
docker-compose exec api alembic upgrade head
```

### Code Issues

**Import errors**:
```bash
# Rebuild container
docker-compose build api

# Check Python path
docker-compose exec api python -c "import sys; print(sys.path)"
```

**Tests failing**:
```bash
# Run with verbose output
docker-compose exec api pytest -v

# Run with print statements
docker-compose exec api pytest -s

# Debug specific test
docker-compose exec api pytest tests/path/to/test.py -v -s
```

## Performance Optimization

### Development Performance

1. **Use Docker build cache** effectively
2. **Limit log output** in development
3. **Use fast database** (PostgreSQL with indexes)
4. **Profile slow endpoints** with timing middleware

### Database Performance

```python
# Use select_related / joinedload
from sqlalchemy.orm import selectinload

query = select(User).options(
    selectinload(User.emotion_entries)
)

# Add indexes for common queries
# See database-design.md for index strategy

# Use connection pooling
# Configured in db/session.py
```

## Security Best Practices

### Development Security

1. **Never commit** `.env` files
2. **Use strong passwords** even in development
3. **Keep dependencies updated**
4. **Validate all inputs** with Pydantic
5. **Use parameterized queries** (SQLAlchemy handles this)

### Code Security

```python
# ✅ Good
from app.core.security import get_password_hash
hashed = get_password_hash(password)

# ❌ Bad
import hashlib
hashed = hashlib.md5(password.encode()).hexdigest()

# ✅ Good (SQL injection safe)
query = select(User).where(User.email == email)

# ❌ Bad
query = f"SELECT * FROM users WHERE email = '{email}'"
```

## Monitoring & Logging

### Application Logs

**Log Levels**:
- `DEBUG`: Detailed information for diagnosing
- `INFO`: General informational messages
- `WARNING`: Warning messages
- `ERROR`: Error messages
- `CRITICAL`: Critical issues

**Logging in Code**:
```python
import logging

logger = logging.getLogger(__name__)

logger.info(f"User {user_id} created entry {entry_id}")
logger.warning(f"Gemini API slow response: {duration}s")
logger.error(f"Failed to generate visualization: {error}")
```

### Performance Monitoring

```python
# Add timing middleware
from fastapi import Request
import time

@app.middleware("http")
async def log_requests(request: Request, call_next):
    start_time = time.time()
    response = await call_next(request)
    duration = time.time() - start_time
    logger.info(f"{request.method} {request.url.path} - {duration:.2f}s")
    return response
```

## Deployment Checklist (Future)

When ready for production (out of scope for 002-backend):

- [ ] Environment variables in secrets manager
- [ ] Strong passwords and API keys
- [ ] SSL/TLS certificates
- [ ] Remove debug flags
- [ ] Set up monitoring (Sentry, DataDog)
- [ ] Configure backup strategy
- [ ] Set up CI/CD pipeline
- [ ] Load testing
- [ ] Security audit
- [ ] Documentation review

## Resources

### Documentation

- FastAPI: https://fastapi.tiangolo.com
- SQLAlchemy: https://docs.sqlalchemy.org
- Alembic: https://alembic.sqlalchemy.org
- Pydantic: https://docs.pydantic.dev
- pytest: https://docs.pytest.org

### Tools

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc
- Adminer: http://localhost:8080 (with `--profile tools`)

### Getting Help

- Project docs: `docs/002-backend/`
- API specs: `docs/002-backend/req/05-api-specifications.md`
- Database design: `docs/002-backend/req/06-database-design.md`
- GitHub Issues: Report bugs and request features

## Next Steps

Once comfortable with the workflow:

1. Review all requirement documents
2. Start implementing core features
3. Write tests alongside code
4. Document your progress in `docs/002-backend/impl/`
5. Create manual/guides in `docs/002-backend/manual/`
