"""
Modul tangkap kamera Pi Camera V3 menggunakan picamera2.
Hantar setiap frame ke backend server untuk analisis AI.
"""
import io
import os
import time
import logging
import threading
import requests
from PIL import Image

logger = logging.getLogger(__name__)

try:
    from picamera2 import Picamera2
    PICAM_OK = True
except ImportError:
    PICAM_OK = False
    logger.warning("picamera2 tidak tersedia — cuba OpenCV fallback")


class CameraCapture:
    def __init__(self, backend_url: str, zone: str = "driveway",
                 interval: float = 2.0, token: str = ""):
        self.backend_url = backend_url.rstrip("/")
        self.zone = zone
        self.interval = interval
        self.token = token
        self._running = False
        self._cam = None
        self._thread = None
        self._fail_count = 0
        self.MAX_FAILS = 10

    def start(self):
        self._init_camera()
        self._running = True
        self._thread = threading.Thread(target=self._loop, daemon=True)
        self._thread.start()
        logger.info(f"Kamera dimulakan → {self.backend_url} | zon={self.zone}")

    def stop(self):
        self._running = False
        try:
            if self._cam and PICAM_OK:
                self._cam.stop()
            elif self._cam:
                self._cam.release()
        except Exception:
            pass

    def _init_camera(self):
        if PICAM_OK:
            try:
                self._cam = Picamera2()
                cfg = self._cam.create_still_configuration(
                    main={"size": (1920, 1080), "format": "RGB888"},
                    lores={"size": (640, 480), "format": "YUV420"},
                    display="lores",
                )
                self._cam.configure(cfg)
                self._cam.start()
                time.sleep(2)   # biarkan kamera warm up
                logger.info("Pi Camera V3 berjaya dimulakan (1080p)")
                return
            except Exception as e:
                logger.error(f"Pi Camera gagal: {e}")

        # Fallback: OpenCV (webcam USB)
        import cv2
        self._cam = cv2.VideoCapture(0)
        self._cam.set(cv2.CAP_PROP_FRAME_WIDTH, 1280)
        self._cam.set(cv2.CAP_PROP_FRAME_HEIGHT, 720)
        logger.warning("Menggunakan webcam USB sebagai fallback")

    def _capture(self) -> bytes:
        """Tangkap satu frame, pulangkan sebagai JPEG bytes."""
        if PICAM_OK and self._cam:
            arr = self._cam.capture_array("main")
            img = Image.fromarray(arr)
            buf = io.BytesIO()
            img.save(buf, format="JPEG", quality=85)
            return buf.getvalue()
        else:
            import cv2
            ok, frame = self._cam.read()
            if ok:
                _, buf = cv2.imencode(".jpg", frame, [cv2.IMWRITE_JPEG_QUALITY, 85])
                return buf.tobytes()
        return b""

    def _loop(self):
        while self._running:
            try:
                data = self._capture()
                if data:
                    self._send(data)
                    self._fail_count = 0
            except Exception as e:
                self._fail_count += 1
                logger.error(f"Ralat capture [{self._fail_count}]: {e}")
                if self._fail_count >= self.MAX_FAILS:
                    logger.critical("Terlalu banyak kegagalan, cuba restart kamera")
                    self._restart_camera()
                    self._fail_count = 0
            time.sleep(self.interval)

    def _send(self, data: bytes):
        hdrs = {}
        if self.token:
            hdrs["Authorization"] = f"Bearer {self.token}"
        resp = requests.post(
            f"{self.backend_url}/api/events/analyze",
            files={"file": ("frame.jpg", data, "image/jpeg")},
            data={"zone": self.zone},
            headers=hdrs,
            timeout=15,
        )
        if resp.status_code == 200:
            r = resp.json()
            if r.get("alert_triggered"):
                logger.warning(
                    f"🚨 AMARAN | Plat: {r.get('plate_number','?')} | "
                    f"Warna: {r.get('vehicle_color','?')} | "
                    f"Jenis: {r.get('vehicle_model','?')}"
                )
            elif r.get("is_whitelisted"):
                logger.info(f"✅ Kenderaan dibenarkan: {r.get('plate_number')}")
        else:
            logger.warning(f"Backend balas {resp.status_code}")

    def _restart_camera(self):
        logger.info("Restart kamera...")
        self.stop()
        time.sleep(3)
        self._init_camera()
