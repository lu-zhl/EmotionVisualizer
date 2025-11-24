# Docker Infrastructure Specification

## Document Information
- **Milestone**: 002-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-24
- **Version**: 1.0

## Overview

This document specifies the Docker-based infrastructure for local development of the EmotionVisualizer backend. The setup prioritizes developer experience with hot-reloading, data persistence, and easy setup.

## Requirements Summary

From `docs/organic/req002.md`:
1. ✅ Docker Compose for orchestration
2. ✅ Local directory mapping for data persistence
3. ✅ Source code volume mounting for hot-reload
4. ✅ Survive container restarts without data loss

## Directory Structure

```
EmotionVisualizer/
├── backend/                    # Backend source code
│   ├── app/
│   │   ├── __init__.py
│   │   ├── main.py           # FastAPI app entry point
│   │   ├── api/              # API routes
│   │   ├── models/           # SQLAlchemy models
│   │   ├── schemas/          # Pydantic schemas
│   │   ├── services/         # Business logic
│   │   ├── core/             # Config, security, etc.
│   │   └── db/               # Database setup
│   ├── tests/
│   ├── alembic/              # Database migrations
│   ├── Dockerfile
│   ├── requirements.txt
│   ├── pyproject.toml
│   └── .env.example
├── docker-compose.yml
└── data/                     # Persistent data (gitignored)
    ├── postgres/             # PostgreSQL data
    └── logs/                 # Application logs
```

## Docker Compose Configuration

### Complete docker-compose.yml

```yaml
version: '3.8'

services:
  # PostgreSQL Database
  db:
    image: postgres:15-alpine
    container_name: emotionvisualizer-db
    environment:
      POSTGRES_USER: ${POSTGRES_USER:-emotionviz}
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-devpassword}
      POSTGRES_DB: ${POSTGRES_DB:-emotionviz_db}
      POSTGRES_HOST_AUTH_METHOD: trust  # For local dev only
    ports:
      - "${POSTGRES_PORT:-5432}:5432"
    volumes:
      # Data persistence - survives container restarts
      - ./data/postgres:/var/lib/postgresql/data
      # Initialization scripts (optional)
      - ./backend/init-scripts:/docker-entrypoint-initdb.d
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U ${POSTGRES_USER:-emotionviz}"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - emotionviz-network
    restart: unless-stopped

  # FastAPI Backend
  api:
    build:
      context: ./backend
      dockerfile: Dockerfile
      target: development
    container_name: emotionvisualizer-api
    command: uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
    environment:
      # Database
      DATABASE_URL: postgresql+asyncpg://${POSTGRES_USER:-emotionviz}:${POSTGRES_PASSWORD:-devpassword}@db:5432/${POSTGRES_DB:-emotionviz_db}

      # External APIs
      GEMINI_API_KEY: ${GEMINI_API_KEY}
      NANOBANANA_API_KEY: ${NANOBANANA_API_KEY}

      # App Config
      DEBUG: "true"
      LOG_LEVEL: ${LOG_LEVEL:-info}

      # Security
      JWT_SECRET_KEY: ${JWT_SECRET_KEY:-dev-secret-key-change-in-production}
      JWT_ALGORITHM: HS256
      ACCESS_TOKEN_EXPIRE_MINUTES: 60

      # CORS
      ALLOWED_ORIGINS: ${ALLOWED_ORIGINS:-http://localhost:*,capacitor://localhost}
    ports:
      - "${API_PORT:-8000}:8000"
    volumes:
      # Source code hot-reload - changes reflect immediately
      - ./backend/app:/app/app:ro
      - ./backend/tests:/app/tests:ro
      - ./backend/alembic:/app/alembic:ro
      # Logs persistence
      - ./data/logs:/app/logs
    depends_on:
      db:
        condition: service_healthy
    networks:
      - emotionviz-network
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s

  # Adminer - Database Management UI (Optional)
  adminer:
    image: adminer:latest
    container_name: emotionvisualizer-adminer
    ports:
      - "${ADMINER_PORT:-8080}:8080"
    environment:
      ADMINER_DEFAULT_SERVER: db
      ADMINER_DESIGN: nette
    depends_on:
      - db
    networks:
      - emotionviz-network
    restart: unless-stopped
    profiles:
      - tools  # Only start with: docker-compose --profile tools up

networks:
  emotionviz-network:
    driver: bridge
    name: emotionviz-network

volumes:
  postgres-data:
    name: emotionviz-postgres-data
```

## Dockerfile Specification

### Multi-stage Dockerfile

```dockerfile
# backend/Dockerfile

# Base stage - common for all targets
FROM python:3.11-slim as base

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Create app directory
WORKDIR /app

# Copy dependency files
COPY requirements.txt pyproject.toml* ./

# Install Python dependencies
RUN pip install --upgrade pip && \
    pip install -r requirements.txt

#######################################################
# Development stage
#######################################################
FROM base as development

# Install development dependencies
RUN pip install \
    pytest \
    pytest-asyncio \
    pytest-cov \
    pytest-mock \
    ruff \
    black \
    mypy \
    ipython \
    httpx

# Copy application code
COPY . .

# Create non-root user for development
RUN useradd -m -u 1000 devuser && \
    chown -R devuser:devuser /app
USER devuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Default command (can be overridden in docker-compose)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]

#######################################################
# Production stage (for future use)
#######################################################
FROM base as production

# Copy only necessary files
COPY ./app /app/app
COPY ./alembic /app/alembic
COPY alembic.ini /app/

# Create non-root user
RUN useradd -m -u 1000 appuser && \
    chown -R appuser:appuser /app
USER appuser

# Expose port
EXPOSE 8000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
  CMD curl -f http://localhost:8000/health || exit 1

# Run with production settings
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4"]
```

## Environment Configuration

### .env.example

```bash
# .env.example - Copy to .env and customize

#######################################################
# Database Configuration
#######################################################
POSTGRES_USER=emotionviz
POSTGRES_PASSWORD=devpassword
POSTGRES_DB=emotionviz_db
POSTGRES_PORT=5432

#######################################################
# API Configuration
#######################################################
API_PORT=8000
LOG_LEVEL=info

#######################################################
# External Services
#######################################################
GEMINI_API_KEY=your-gemini-api-key-here
NANOBANANA_API_KEY=your-nanobanana-api-key-here

#######################################################
# Security (Change in production!)
#######################################################
JWT_SECRET_KEY=dev-secret-key-please-change-this-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=60

#######################################################
# CORS Configuration
#######################################################
ALLOWED_ORIGINS=http://localhost:*,capacitor://localhost,ionic://localhost

#######################################################
# Adminer (Optional)
#######################################################
ADMINER_PORT=8080
```

### .gitignore Additions

```gitignore
# Backend specific
backend/.env
backend/__pycache__/
backend/*.pyc
backend/.pytest_cache/
backend/.mypy_cache/
backend/.ruff_cache/
backend/.coverage
backend/htmlcov/

# Docker data
data/
!data/.gitkeep

# Logs
*.log
logs/
```

## Volume Mounting Strategy

### 1. Source Code Volumes (Hot-Reload)

```yaml
volumes:
  - ./backend/app:/app/app:ro  # Read-only for safety
  - ./backend/tests:/app/tests:ro
```

**Benefits**:
- Code changes immediately reflected
- No rebuild needed during development
- Fast iteration cycle

**Limitations**:
- Dependency changes require rebuild
- Configuration changes may need restart

### 2. Data Persistence Volumes

```yaml
volumes:
  - ./data/postgres:/var/lib/postgresql/data  # PostgreSQL data
  - ./data/logs:/app/logs  # Application logs
```

**Benefits**:
- Data survives `docker-compose down`
- Easy to backup (just copy `data/` directory)
- No data loss on container restart

**Important**: Add `data/` to `.gitignore`

## Container Lifecycle Management

### Starting Services

```bash
# Start all services
docker-compose up -d

# Start with database UI tool
docker-compose --profile tools up -d

# View logs
docker-compose logs -f api

# View specific service logs
docker-compose logs -f db
```

### Stopping Services

```bash
# Stop containers (keeps data)
docker-compose stop

# Stop and remove containers (keeps data in volumes)
docker-compose down

# Remove everything including volumes (CAUTION: loses data)
docker-compose down -v
```

### Rebuilding

```bash
# Rebuild after dependency changes
docker-compose build api

# Force rebuild without cache
docker-compose build --no-cache api

# Rebuild and restart
docker-compose up -d --build
```

## Database Management

### Running Migrations

```bash
# Inside API container
docker-compose exec api alembic upgrade head

# Create new migration
docker-compose exec api alembic revision --autogenerate -m "description"

# Rollback migration
docker-compose exec api alembic downgrade -1
```

### Database Backup

```bash
# Backup database
docker-compose exec db pg_dump -U emotionviz emotionviz_db > backup.sql

# Restore database
docker-compose exec -T db psql -U emotionviz emotionviz_db < backup.sql
```

### Accessing Database

```bash
# psql command line
docker-compose exec db psql -U emotionviz -d emotionviz_db

# Via Adminer UI
# Open http://localhost:8080 in browser
# Server: db
# Username: emotionviz
# Password: devpassword
# Database: emotionviz_db
```

## Networking

### Service Communication

- Services communicate via service names (DNS)
- Example: API connects to `db:5432` (not `localhost:5432`)
- iOS app connects to `localhost:8000` (port mapped to host)

### Network Isolation

- Custom bridge network: `emotionviz-network`
- Isolated from other Docker networks
- Services can only access each other within network

## Health Checks

### API Health Check

```bash
# From host
curl http://localhost:8000/health

# Expected response
{
  "status": "healthy",
  "timestamp": "2025-11-24T12:00:00Z"
}
```

### Database Health Check

```bash
# Check if accepting connections
docker-compose exec db pg_isready -U emotionviz

# Expected output
/var/run/postgresql:5432 - accepting connections
```

## Development Workflow

### Initial Setup

```bash
# 1. Clone repository
git clone <repo-url>
cd EmotionVisualizer

# 2. Create environment file
cp backend/.env.example backend/.env
# Edit .env with your API keys

# 3. Create data directories
mkdir -p data/postgres data/logs

# 4. Start services
docker-compose up -d

# 5. Wait for services to be healthy
docker-compose ps

# 6. Run migrations
docker-compose exec api alembic upgrade head

# 7. Verify API is running
curl http://localhost:8000/health
```

### Daily Development

```bash
# Start services
docker-compose up -d

# Make code changes (hot-reload automatically)
# Edit files in backend/app/

# View logs
docker-compose logs -f api

# Run tests
docker-compose exec api pytest

# Stop services
docker-compose stop
```

### Adding Dependencies

```bash
# 1. Update requirements.txt
echo "new-package==1.0.0" >> backend/requirements.txt

# 2. Rebuild container
docker-compose build api

# 3. Restart service
docker-compose up -d api
```

## Troubleshooting

### Container Won't Start

```bash
# Check logs
docker-compose logs api

# Check container status
docker-compose ps

# Restart service
docker-compose restart api
```

### Database Connection Issues

```bash
# Verify database is running
docker-compose ps db

# Check database logs
docker-compose logs db

# Test connection
docker-compose exec api python -c "from app.db.session import engine; print(engine)"
```

### Port Already in Use

```bash
# Find process using port
lsof -i :8000

# Change port in docker-compose.yml or .env
API_PORT=8001
```

### Data Corruption

```bash
# Stop all services
docker-compose down

# Remove data directory (CAUTION: loses all data)
rm -rf data/postgres

# Recreate directory
mkdir -p data/postgres

# Restart services
docker-compose up -d

# Re-run migrations
docker-compose exec api alembic upgrade head
```

## Performance Optimization

### Resource Limits

```yaml
# Add to docker-compose.yml services
api:
  deploy:
    resources:
      limits:
        cpus: '2.0'
        memory: 2G
      reservations:
        cpus: '0.5'
        memory: 512M
```

### Build Optimization

```dockerfile
# Use build cache effectively
# Order commands from least to most frequently changed
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .  # This layer changes most often
```

## Security Considerations

### Development Security

- ⚠️ Default passwords are for **local development only**
- ⚠️ Never commit `.env` file with real credentials
- ⚠️ Use `POSTGRES_HOST_AUTH_METHOD: trust` only locally
- ⚠️ Bind to `127.0.0.1` if exposing services to network

### Production Checklist (Out of Scope)

- [ ] Strong passwords
- [ ] SSL/TLS certificates
- [ ] Remove debug flags
- [ ] Proper authentication on database
- [ ] Network security groups
- [ ] Secrets management (not .env files)

## Monitoring & Logging

### Log Locations

```yaml
# Application logs
- ./data/logs/app.log

# Docker logs
docker-compose logs -f

# PostgreSQL logs (in container)
docker-compose exec db cat /var/log/postgresql/postgresql.log
```

### Log Rotation

```yaml
# Add to docker-compose.yml services
api:
  logging:
    driver: "json-file"
    options:
      max-size: "10m"
      max-file: "3"
```

## Next Steps

1. Set up Docker infrastructure based on this specification
2. Test hot-reload functionality
3. Verify data persistence across restarts
4. Document any issues or improvements needed
5. Begin API implementation (see `05-api-specifications.md`)
