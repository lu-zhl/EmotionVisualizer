# EmotionVisualizer Backend Setup

## Overview

The backend is a Python/FastAPI service running in Docker containers with PostgreSQL database.

## Architecture

- **API Server**: FastAPI (Python 3.11) running on `http://localhost:8000`
- **Database**: PostgreSQL 15 running on `localhost:5432`
- **Optional**: Adminer database UI on `http://localhost:8080` (with `--profile tools`)

## Prerequisites

- Docker and Docker Compose (or OrbStack)
- Git

## Quick Start

1. **Start the backend**:
   ```bash
   cd /Users/lulu/EmotionVisualizer
   docker-compose up -d
   ```

2. **Check status**:
   ```bash
   docker-compose ps
   ```

   You should see both `emotionvisualizer-api` and `emotionvisualizer-db` running.

3. **View logs**:
   ```bash
   docker-compose logs -f api
   ```

4. **Test the API**:
   ```bash
   curl http://localhost:8000/health
   ```

   Expected response:
   ```json
   {"status": "healthy", "version": "1.0.0"}
   ```

## API Endpoints

### Health Check
```
GET http://localhost:8000/health
```

### Authentication
```
POST http://localhost:8000/api/v1/auth/register
POST http://localhost:8000/api/v1/auth/login
GET  http://localhost:8000/api/v1/auth/me
```

### Emotion Entries
```
GET    http://localhost:8000/api/v1/entries
POST   http://localhost:8000/api/v1/entries
GET    http://localhost:8000/api/v1/entries/{id}
PUT    http://localhost:8000/api/v1/entries/{id}
DELETE http://localhost:8000/api/v1/entries/{id}
```

### API Documentation
Visit `http://localhost:8000/docs` for interactive Swagger UI documentation.

## Database Management

### Run Migrations
```bash
docker-compose exec api alembic upgrade head
```

### Create New Migration
```bash
docker-compose exec api alembic revision --autogenerate -m "description"
```

### Access Database
```bash
# Using psql
docker-compose exec db psql -U emotionviz -d emotionviz_db

# Using Adminer (web UI)
docker-compose --profile tools up -d
# Then open http://localhost:8080
```

## Development Workflow

### Making Code Changes

The backend code is hot-reloaded automatically. Just edit files in `backend/app/` and the server will restart.

### Adding Dependencies

1. Edit `backend/requirements.txt`
2. Rebuild the container:
   ```bash
   docker-compose build api
   docker-compose up -d api
   ```

### Viewing Logs
```bash
# All services
docker-compose logs -f

# Just API
docker-compose logs -f api

# Just Database
docker-compose logs -f db
```

## iOS Integration

### APIService.swift

The iOS app includes `APIService.swift` which provides:

- `register(email:password:name:)` - Register new user
- `login(email:password:)` - Login existing user
- `createEntry(situation:emotions:intensity:notes:)` - Create emotion entry
- `testConnection()` - Test backend connectivity

### BackendTestView.swift

A test view is provided to demonstrate the integration. You can:

1. Test connection to backend
2. Register/login users
3. Create emotion entries
4. See real-time status messages

### Running the Test View

Add this to your app to access the test view:
```swift
NavigationLink("Backend Test") {
    BackendTestView()
}
```

## Troubleshooting

### Backend Not Starting
```bash
# Check Docker is running
docker ps

# View logs for errors
docker-compose logs api

# Rebuild containers
docker-compose down
docker-compose up -d --build
```

### Database Connection Issues
```bash
# Check database is healthy
docker-compose ps db

# Restart database
docker-compose restart db
```

### API Returns 500 Errors
```bash
# Check API logs
docker-compose logs --tail=50 api

# Check database migrations are applied
docker-compose exec api alembic current
```

### iOS App Can't Connect

1. Ensure backend is running: `curl http://localhost:8000/health`
2. Check iOS simulator can access localhost (it should by default)
3. For physical device, use your computer's IP address instead of `localhost` in `APIService.swift`

## Stopping the Backend

```bash
# Stop containers (keeps data)
docker-compose stop

# Stop and remove containers (keeps data)
docker-compose down

# Remove everything including data (CAUTION)
docker-compose down -v
```

## API Keys

### Gemini API
To enable AI features, add your Gemini API key to `backend/.env`:
```
GEMINI_API_KEY=your-api-key-here
```

### Restart after adding keys
```bash
docker-compose restart api
```

## Data Persistence

All data is stored in the `data/` directory:
- `data/postgres/` - Database files
- `data/logs/` - Application logs

This directory is gitignored and persists across container restarts.

## Next Steps

1. Add your Gemini API key to enable AI features
2. Implement visualization service integration (Nano Banana Pro)
3. Extend the iOS app to use all backend endpoints
4. Add more comprehensive error handling

## Support

For issues or questions:
- Check logs: `docker-compose logs -f api`
- View API docs: http://localhost:8000/docs
- Review requirements: `docs/002-backend/req/`
