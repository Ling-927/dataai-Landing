import io
import numpy as np
from fastapi import APIRouter, Depends, UploadFile, File, Form, Query
from sqlalchemy.orm import Session
from typing import Optional, List
from PIL import Image
from ..core.database import get_db
from ..models.models import DetectionEvent, AlertStatus
from .auth import get_current_user

router = APIRouter(prefix="/events", tags=["events"])


def _get_services():
    from ..main import detection_service
    return detection_service


@router.get("/", response_model=List[dict])
def list_events(
    skip: int = 0,
    limit: int = 50,
    whitelisted: Optional[bool] = None,
    alert_only: bool = False,
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    q = db.query(DetectionEvent).order_by(DetectionEvent.timestamp.desc())
    if whitelisted is not None:
        q = q.filter(DetectionEvent.is_whitelisted == whitelisted)
    if alert_only:
        q = q.filter(DetectionEvent.alert_triggered == True)
    events = q.offset(skip).limit(limit).all()
    return [_event_to_dict(e) for e in events]


@router.get("/stats")
def get_stats(db: Session = Depends(get_db), _=Depends(get_current_user)):
    total = db.query(DetectionEvent).count()
    alerts = db.query(DetectionEvent).filter(DetectionEvent.alert_triggered == True).count()
    whitelisted = db.query(DetectionEvent).filter(DetectionEvent.is_whitelisted == True).count()
    return {"total": total, "alerts": alerts, "whitelisted": whitelisted, "unknown": total - whitelisted}


@router.post("/analyze")
async def analyze_image(
    file: UploadFile = File(...),
    zone: Optional[str] = Form(None),
    db: Session = Depends(get_db),
    _=Depends(get_current_user),
):
    """Upload a photo for manual analysis."""
    contents = await file.read()
    img = Image.open(io.BytesIO(contents)).convert("RGB")
    img_np = np.array(img)[:, :, ::-1]

    svc = _get_services()
    event = svc.process_frame(img_np, zone=zone)
    return _event_to_dict(event)


@router.put("/{event_id}/acknowledge")
def acknowledge(event_id: int, db: Session = Depends(get_db), _=Depends(get_current_user)):
    event = db.query(DetectionEvent).filter(DetectionEvent.id == event_id).first()
    if event:
        event.alert_status = AlertStatus.ACKNOWLEDGED
        db.commit()
    return {"message": "Acknowledged"}


def _event_to_dict(e: DetectionEvent) -> dict:
    return {
        "id": e.id,
        "timestamp": e.timestamp,
        "plate_number": e.plate_number,
        "plate_confidence": e.plate_confidence,
        "vehicle_make": e.vehicle_make,
        "vehicle_model": e.vehicle_model,
        "vehicle_color": e.vehicle_color,
        "face_recognized": e.face_recognized,
        "face_name": e.face_name,
        "is_whitelisted": e.is_whitelisted,
        "alert_triggered": e.alert_triggered,
        "alert_status": e.alert_status,
        "whatsapp_sent": e.whatsapp_sent,
        "image_path": e.image_path,
        "zone": e.zone,
    }
