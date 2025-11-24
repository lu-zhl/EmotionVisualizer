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
COPY requirements.txt ./

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

# Default command (can be overridden in docker-compose)
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
