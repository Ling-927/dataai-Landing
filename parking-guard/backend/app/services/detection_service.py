"""
Orchestrates detection pipeline: AI analysis → whitelist check → alert decision → GPIO → WhatsApp.
"""
import os
import cv2
import logging
import asyncio
import numpy as np
from datetime import datetime
from typing import Optional
from sqlalchemy.orm import Session

from .ai_service import AIService, RecognitionResult
from .notification_service import NotificationService
from ..models.models import DetectionEvent, WhitelistPlate, AlertStatus
from ..core.config import settings

logger = logging.getLogger(__name__)


class DetectionService:
    def __init__(self, db: Session, ai: AIService, notifier: NotificationService):
        self.db = db
        self.ai = ai
        self.notifier = notifier
        self._alert_cooldown: dict = {}
        self.COOLDOWN_SECONDS = 60

    def is_whitelisted(self, plate: str) -> bool:
        if not plate:
            return False
        normalized = plate.upper().replace(" ", "").replace("-", "")
        entry = (
            self.db.query(WhitelistPlate)
            .filter(
                WhitelistPlate.plate_number == normalized,
                WhitelistPlate.is_active == True,
            )
            .first()
        )
        return entry is not None

    def _in_cooldown(self, plate: str) -> bool:
        if plate in self._alert_cooldown:
            elapsed = (datetime.utcnow() - self._alert_cooldown[plate]).total_seconds()
            return elapsed < self.COOLDOWN_SECONDS
        return False

    def process_frame(self, image_np: np.ndarray, zone: Optional[str] = None) -> DetectionEvent:
        result: RecognitionResult = self.ai.analyze_frame(image_np)

        plate_num = result.plate.plate_number if result.plate else None
        plate_conf = result.plate.confidence if result.plate else None
        vehicle_color = result.vehicle.color if result.vehicle else "unknown"
        vehicle_type = result.vehicle.model if result.vehicle else "unknown"
        face_name = next((f.name for f in result.faces if f.confidence > 0.6), None)

        whitelisted = self.is_whitelisted(plate_num) if plate_num else False
        owner_face = result.owner_face_detected

        alert_needed = (
            plate_num is not None
            and not whitelisted
            and not owner_face
            and not self._in_cooldown(plate_num or "")
        )

        image_path = None
        if plate_num or owner_face:
            image_path = self._save_image(image_np, plate_num)

        event = DetectionEvent(
            plate_number=plate_num,
            plate_confidence=plate_conf,
            vehicle_make=result.vehicle.make if result.vehicle else None,
            vehicle_model=vehicle_type,
            vehicle_color=vehicle_color,
            face_recognized=face_name is not None,
            face_name=face_name,
            is_whitelisted=whitelisted,
            alert_triggered=alert_needed,
            alert_status=AlertStatus.PENDING if alert_needed else AlertStatus.DISMISSED,
            image_path=image_path,
            zone=zone,
        )
        self.db.add(event)
        self.db.commit()
        self.db.refresh(event)

        if alert_needed:
            self._alert_cooldown[plate_num] = datetime.utcnow()
            asyncio.create_task(self._trigger_alerts(event, image_path))
        elif not whitelisted and owner_face and plate_num:
            self.notifier.send_owner_face_bypass(plate_num, face_name or "Tuan Rumah")

        return event

    async def _trigger_alerts(self, event: DetectionEvent, image_path: Optional[str]):
        await asyncio.gather(
            self._trigger_gpio(),
            self._send_whatsapp(event, image_path),
        )
        event.alert_status = AlertStatus.NOTIFIED
        self.db.commit()

    async def _trigger_gpio(self):
        try:
            import httpx
            async with httpx.AsyncClient(timeout=5) as client:
                await client.post(f"{settings.PI_API_URL}/alert/trigger", json={"duration": 10})
        except Exception as e:
            logger.error(f"GPIO trigger failed: {e}")

    async def _send_whatsapp(self, event: DetectionEvent, image_path: Optional[str]):
        image_url = None
        if image_path and os.path.exists(image_path):
            image_url = f"{settings.PI_API_URL}/uploads/{os.path.basename(image_path)}"

        sent = self.notifier.send_whatsapp_alert(
            plate_number=event.plate_number or "TIDAK DIKESAN",
            vehicle_color=event.vehicle_color or "unknown",
            vehicle_type=event.vehicle_model or "Kenderaan",
            image_url=image_url,
            zone=event.zone,
        )
        event.whatsapp_sent = sent
        self.db.commit()

    def _save_image(self, image_np: np.ndarray, plate: Optional[str]) -> Optional[str]:
        try:
            os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
            ts = datetime.utcnow().strftime("%Y%m%d_%H%M%S")
            fname = f"{ts}_{plate or 'unknown'}.jpg"
            path = os.path.join(settings.UPLOAD_DIR, fname)
            cv2.imwrite(path, image_np)
            return path
        except Exception as e:
            logger.error(f"Save image failed: {e}")
            return None
