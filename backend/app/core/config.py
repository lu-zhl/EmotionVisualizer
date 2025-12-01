from pydantic_settings import BaseSettings
from typing import List


class Settings(BaseSettings):
    # App
    APP_NAME: str = "EmotionVisualizer"
    DEBUG: bool = True
    LOG_LEVEL: str = "info"

    # Database
    DATABASE_URL: str

    # External APIs
    GEMINI_API_KEY: str
    NANOBANANA_API_KEY: str = ""

    # Visualization Settings
    GEMINI_MODEL: str = "gemini-2.0-flash"
    GEMINI_TIMEOUT_SECONDS: int = 30
    GEMINI_MAX_RETRIES: int = 2
    VISUALIZATION_IMAGE_SIZE: int = 512

    # Security
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60

    # CORS
    ALLOWED_ORIGINS: str = "http://localhost:*,capacitor://localhost"

    @property
    def cors_origins(self) -> List[str]:
        """Parse CORS origins from comma-separated string"""
        return [origin.strip() for origin in self.ALLOWED_ORIGINS.split(",")]

    class Config:
        env_file = ".env"
        case_sensitive = True
        extra = "ignore"  # Ignore extra fields from environment


settings = Settings()
