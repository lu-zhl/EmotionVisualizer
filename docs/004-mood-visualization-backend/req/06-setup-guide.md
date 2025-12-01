# Setup Guide - Mood Visualization Backend

## Document Information
- **Milestone**: 004-mood-visualization-backend
- **Author**: Documentation Writer (AI Agent)
- **Date**: 2025-11-26
- **Version**: 1.0

---

## 1. Prerequisites

- Python 3.11+
- Docker and Docker Compose (if using containerized setup)
- Google account for Gemini API access

## 2. Get Gemini API Key

### Step 1: Access Google AI Studio

1. Go to [Google AI Studio](https://aistudio.google.com/)
2. Sign in with your Google account

### Step 2: Create API Key

1. Click **"Get API key"** in the left sidebar
2. Click **"Create API key"**
3. Select a Google Cloud project (or create a new one)
4. Copy the generated API key

### Step 3: Store Securely

- Never commit API keys to version control
- Never share API keys publicly
- Rotate keys periodically

## 3. Configure Environment

### For Local Development (Recommended)

Create a `.env` file in the `backend/` directory:

```bash
# backend/.env

# ===================
# Gemini API Configuration
# ===================
GEMINI_API_KEY=your_api_key_here
GEMINI_MODEL=gemini-2.0-flash-exp
GEMINI_TIMEOUT_SECONDS=30
GEMINI_MAX_RETRIES=2

# ===================
# Server Configuration
# ===================
DEBUG=true
LOG_LEVEL=DEBUG
```

**Important**: Ensure `.env` is in your `.gitignore` file!

### Verify .gitignore

Check that `backend/.gitignore` contains:

```
.env
.env.local
.env.*.local
```

## 4. Quick Start

### Option A: Using Docker (Recommended)

```bash
# From project root
cd backend

# Copy example env file
cp .env.example .env

# Edit .env and add your GEMINI_API_KEY
nano .env  # or use your preferred editor

# Start services
docker-compose up -d

# Check logs
docker-compose logs -f backend
```

### Option B: Local Python Environment

```bash
# From project root
cd backend

# Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Copy example env file
cp .env.example .env

# Edit .env and add your GEMINI_API_KEY
nano .env

# Run server
uvicorn app.main:app --reload --port 8000
```

## 5. Verify Setup

### Test Health Endpoint

```bash
curl http://localhost:8000/health
```

Expected response:
```json
{
  "status": "healthy",
  "timestamp": "2025-11-26T12:00:00Z",
  "version": "1.0.0"
}
```

### Test Visualization Health

```bash
curl http://localhost:8000/api/v1/visualizations/health
```

Expected response (if Gemini API is configured correctly):
```json
{
  "status": "healthy",
  "checks": {
    "gemini_api": {
      "status": "healthy",
      "latency_ms": 150
    }
  }
}
```

### Test Visualization Generation

```bash
curl -X POST http://localhost:8000/api/v1/visualizations/generate \
  -H "Content-Type: application/json" \
  -d '{
    "selected_emotions": ["content", "chill"]
  }'
```

Expected response:
```json
{
  "success": true,
  "data": {
    "image_data": "base64_encoded_png...",
    "image_format": "png",
    "image_size": {"width": 512, "height": 512},
    "prompt_used": "...",
    "generation_time_ms": 3500
  }
}
```

## 6. Troubleshooting

### "GEMINI_API_KEY environment variable is required"

**Cause**: API key not set or `.env` file not loaded

**Solution**:
1. Verify `.env` file exists in `backend/` directory
2. Check the key is set: `echo $GEMINI_API_KEY`
3. Restart the server after adding the key

### "Invalid API key"

**Cause**: Incorrect or expired API key

**Solution**:
1. Verify the key in [Google AI Studio](https://aistudio.google.com/)
2. Generate a new key if needed
3. Update `.env` file and restart server

### "Gemini API unavailable" / 503 Error

**Cause**: Cannot reach Gemini API

**Solution**:
1. Check internet connection
2. Verify Gemini API status at [Google Cloud Status](https://status.cloud.google.com/)
3. Check if API key has billing enabled (some features require it)

### "Generation timeout" / 504 Error

**Cause**: Image generation taking too long

**Solution**:
1. Try again (temporary API slowness)
2. Increase `GEMINI_TIMEOUT_SECONDS` in `.env`
3. Simplify the input (shorter text, fewer emotions)

## 7. Environment Variables Reference

| Variable | Required | Default | Description |
|----------|----------|---------|-------------|
| `GEMINI_API_KEY` | **Yes** | - | Your Google Gemini API key |
| `GEMINI_MODEL` | No | `gemini-2.0-flash-exp` | Gemini model to use |
| `GEMINI_TIMEOUT_SECONDS` | No | `30` | Request timeout |
| `GEMINI_MAX_RETRIES` | No | `2` | Retry attempts on failure |
| `DEBUG` | No | `false` | Enable debug mode |
| `LOG_LEVEL` | No | `INFO` | Logging level |

## 8. Next Steps

After setup is complete:

1. Test the visualization endpoint with different inputs
2. Integrate with iOS app's `DrawMyFeelingsViewModel`
3. Monitor API usage in Google Cloud Console
