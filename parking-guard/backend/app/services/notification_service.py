"""
WhatsApp notification via Twilio. Sends alert with detection image when unauthorized vehicle detected.
"""
import logging
from typing import Optional
from ..core.config import settings

logger = logging.getLogger(__name__)


class NotificationService:
    def __init__(self):
        self.client = None
        self._init_twilio()

    def _init_twilio(self):
        if settings.TWILIO_ACCOUNT_SID and settings.TWILIO_AUTH_TOKEN:
            try:
                from twilio.rest import Client
                self.client = Client(settings.TWILIO_ACCOUNT_SID, settings.TWILIO_AUTH_TOKEN)
                logger.info("Twilio client initialised")
            except Exception as e:
                logger.error(f"Twilio init failed: {e}")

    def send_whatsapp_alert(
        self,
        plate_number: str,
        vehicle_color: str,
        vehicle_type: str,
        image_url: Optional[str] = None,
        zone: Optional[str] = None,
        to_number: Optional[str] = None,
    ) -> bool:
        if not self.client:
            logger.warning("Twilio not configured — skipping WhatsApp alert")
            return False

        to = to_number or settings.OWNER_WHATSAPP
        if not to:
            logger.warning("No WhatsApp destination configured")
            return False

        zone_text = f" di kawasan *{zone}*" if zone else ""
        body = (
            f"🚨 *AMARAN PARKINGGUARD*\n\n"
            f"Kenderaan tidak dibenarkan dikesan{zone_text}!\n\n"
            f"🚗 No. Plat: *{plate_number}*\n"
            f"🎨 Warna: {vehicle_color.capitalize()}\n"
            f"🚙 Jenis: {vehicle_type}\n\n"
            f"Sila semak kamera segera."
        )

        try:
            kwargs = {
                "from_": settings.TWILIO_WHATSAPP_FROM,
                "body": body,
                "to": to,
            }
            if image_url:
                kwargs["media_url"] = [image_url]

            msg = self.client.messages.create(**kwargs)
            logger.info(f"WhatsApp sent: {msg.sid}")
            return True
        except Exception as e:
            logger.error(f"WhatsApp send failed: {e}")
            return False

    def send_owner_face_bypass(self, plate_number: str, owner_name: str) -> bool:
        """Notify owner that face recognition bypassed plate alert."""
        if not self.client:
            return False
        to = settings.OWNER_WHATSAPP
        if not to:
            return False
        try:
            body = (
                f"✅ *I Defender — Muka Dikenali*\n\n"
                f"Plat *{plate_number}* bukan dalam senarai putih,\n"
                f"tetapi muka *{owner_name}* telah dikenali.\n"
                f"Tiada amaran dikeluarkan."
            )
            self.client.messages.create(
                from_=settings.TWILIO_WHATSAPP_FROM, body=body, to=to
            )
            return True
        except Exception as e:
            logger.error(f"Face bypass notification failed: {e}")
            return False
