"""
Pi Camera V3 capture module using picamera2.
Captures frames continuously and sends to backend server for analysis.
"""
import io
import time
import logging
import threading
import requests
import numpy as np
from PIL import Image

logger = logging.getLogger(__name__)

try:
    from picamera2 import Picamera2
    PICAM_AVAILABLE = True
except ImportError:
    PICAM_AVAILABLE = False
    logger.warning("picamera2 not available — using OpenCV fallback")


class CameraCapture:
    def __init__(self, backend_url: str, zone: str = "driveway", interval: float = 2.0):
        self.backend_url = backend_url
        self.zone = zone
        self.interval = interval
        self._running = False
        self._cam = None
        self._thread = None

    def start(self):
        self._running = True
        self._init_camera()
        self._thread = threading.Thread(target=self._loop, daemon=True)
        self._thread.start()
        logger.info("Camera capture started")

    def stop(self):
        self._running = False
        if self._cam and PICAM_AVAILABLE:
            self._cam.stop()

    def _init_camera(self):
        if PICAM_AVAILABLE:
            self._cam = Picamera2()
            config = self._cam.create_still_configuration(
                main={"size": (1920, 1080)},
                lores={"size": (640, 480)},
            )
            self._cam.configure(config)
            self._cam.start()
            time.sleep(1)
        else:
            import cv2
            self._cam = cv2.VideoCapture(0)

    def _capture_frame(self) -> bytes:
        if PICAM_AVAILABLE and self._cam:
            arr = self._cam.capture_array("lores")
            img = Image.fromarray(arr)
            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=85)
            return buf.getvalue()
        else:
            import cv2
            ret, frame = self._cam.read()
            if ret:
                _, buf = cv2.imencode(".jpg", frame)
                return buf.tobytes()
        return b""

    def _loop(self):
        while self._running:
            try:
                frame_bytes = self._capture_frame()
                if frame_bytes:
                    self._send_frame(frame_bytes)
            except Exception as e:
                logger.error(f"Capture loop error: {e}")
            time.sleep(self.interval)

    def _send_frame(self, frame_bytes: bytes):
        try:
            resp = requests.post(
                f"{self.backend_url}/api/events/analyze",
                files={"file": ("frame.jpg", frame_bytes, "image/jpeg")},
                data={"zone": self.zone},
                timeout=10,
            )
            if resp.status_code == 200:
                result = resp.json()
                if result.get("alert_triggered"):
                    logger.warning(f"ALERT: plate={result.get('plate_number')} color={result.get('vehicle_color')}")
        except Exception as e:
            logger.error(f"Frame send error: {e}")
