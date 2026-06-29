import os
import logging
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from contextlib import asynccontextmanager

from .core.config import settings
from .core.database import Base, engine, SessionLocal
from .api import auth, whitelist, faces, events, stream
from .services.ai_service import AIService
from .services.notification_service import NotificationService
from .services.detection_service import DetectionService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

ai_service: AIService = None
notifier: NotificationService = None
detection_service: DetectionService = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    global ai_service, notifier, detection_service
    Base.metadata.create_all(bind=engine)
    os.makedirs(settings.UPLOAD_DIR, exist_ok=True)

    ai_service = AIService(
        yolo_model_path=settings.YOLO_MODEL_PATH,
        face_encodings_path=settings.FACE_ENCODINGS_PATH,
    )
    notifier = NotificationService()
    db = SessionLocal()
    detection_service = DetectionService(db=db, ai=ai_service, notifier=notifier)
    logger.info("I Defender backend started")
    yield
    db.close()


app = FastAPI(
    title="I Defender API",
    version=settings.APP_VERSION,
    description="Sistem Pengawasan Kenderaan & Pengenalan Muka",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router, prefix="/api")
app.include_router(whitelist.router, prefix="/api")
app.include_router(faces.router, prefix="/api")
app.include_router(events.router, prefix="/api")
app.include_router(stream.router, prefix="/api")

os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")


@app.get("/")
def root():
    return {"service": "I Defender API", "version": settings.APP_VERSION, "status": "running"}


@app.get("/health")
def health():
    return {"status": "ok"}
