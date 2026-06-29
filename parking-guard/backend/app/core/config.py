from pydantic_settings import BaseSettings
from typing import Optional


class Settings(BaseSettings):
    APP_NAME: str = "I Defender"
    APP_VERSION: str = "1.0.0"
    SECRET_KEY: str = "change-this-secret"
    DEBUG: bool = False
    HOST: str = "0.0.0.0"
    PORT: int = 8000

    DATABASE_URL: str = "sqlite:///./i_defender.db"
    REDIS_URL: str = "redis://localhost:6379"

    TWILIO_ACCOUNT_SID: Optional[str] = None
    TWILIO_AUTH_TOKEN: Optional[str] = None
    TWILIO_WHATSAPP_FROM: str = "whatsapp:+14155238886"
    OWNER_WHATSAPP: Optional[str] = None

    PI_STREAM_URL: str = "http://raspberrypi.local:8554/stream"
    PI_API_URL: str = "http://raspberrypi.local:5000"

    UPLOAD_DIR: str = "./uploads"
    MAX_FILE_SIZE: int = 10485760

    YOLO_MODEL_PATH: str = "./ai-models/yolov8n.pt"
    PLATE_MODEL_PATH: str = "./ai-models/plate_detector.pt"
    FACE_ENCODINGS_PATH: str = "./ai-models/face_encodings.pkl"

    ACCESS_TOKEN_EXPIRE_MINUTES: int = 1440

    class Config:
        env_file = ".env"


settings = Settings()
