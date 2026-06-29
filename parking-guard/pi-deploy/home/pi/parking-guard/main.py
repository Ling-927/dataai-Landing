#!/usr/bin/env python3
"""
ParkingGuard — Raspberry Pi 4 Main Service
Jalankan Flask API (untuk terima arahan GPIO dari backend)
+ Camera capture loop (hantar frame ke backend AI)
"""
import os
import sys
import signal
import logging
from dotenv import load_dotenv

# Muat konfigurasi
load_dotenv(os.path.join(os.path.dirname(__file__), "config.env"))

LOG_LEVEL = os.getenv("LOG_LEVEL", "INFO")
logging.basicConfig(
    level=getattr(logging, LOG_LEVEL),
    format="%(asctime)s [%(levelname)s] %(name)s: %(message)s",
    handlers=[
        logging.StreamHandler(sys.stdout),
        logging.FileHandler("/home/pi/parking-guard/parkingguard.log", mode="a"),
    ],
)
logger = logging.getLogger("main")

BACKEND_URL       = os.getenv("BACKEND_URL", "http://192.168.1.100:8000")
ZONE              = os.getenv("ZONE", "driveway")
CAPTURE_INTERVAL  = float(os.getenv("CAPTURE_INTERVAL", "2.0"))
FLASK_PORT        = int(os.getenv("FLASK_PORT", "5000"))

logger.info("=" * 50)
logger.info("  ParkingGuard Pi Service")
logger.info(f"  Backend : {BACKEND_URL}")
logger.info(f"  Zon     : {ZONE}")
logger.info(f"  Interval: {CAPTURE_INTERVAL}s")
logger.info("=" * 50)

from gpio.controller import GPIOController
from camera.capture import CameraCapture
from flask import Flask, request, jsonify

gpio   = GPIOController()
camera = CameraCapture(
    backend_url=BACKEND_URL,
    zone=ZONE,
    interval=CAPTURE_INTERVAL,
)

# ── Flask API (terima arahan dari backend server) ──────────────
app = Flask(__name__)
app.logger.setLevel(logging.WARNING)  # suppress Flask request logs

@app.route("/health")
def health():
    return jsonify({"status": "ok", "zone": ZONE, "backend": BACKEND_URL})


@app.route("/alert/trigger", methods=["POST"])
def trigger_alert():
    data = request.get_json(silent=True) or {}
    duration = float(data.get("duration", 10))
    gpio.trigger_alert(duration=duration)
    logger.info(f"Alert dicetuskan ({duration}s)")
    return jsonify({"ok": True, "duration": duration})


@app.route("/alert/stop", methods=["POST"])
def stop_alert():
    gpio.stop_alert()
    logger.info("Alert dihentikan oleh arahan")
    return jsonify({"ok": True})


@app.route("/gpio/test", methods=["POST"])
def test_gpio():
    gpio.test_all()
    return jsonify({"ok": True, "msg": "GPIO ujian selesai"})


@app.route("/camera/restart", methods=["POST"])
def restart_camera():
    camera.stop()
    import time; time.sleep(2)
    camera.start()
    return jsonify({"ok": True})


# ── Pengendalian signal ────────────────────────────────────────
def shutdown(sig, frame):
    logger.info("Mematikan ParkingGuard Pi Service...")
    camera.stop()
    gpio.cleanup()
    sys.exit(0)

signal.signal(signal.SIGINT,  shutdown)
signal.signal(signal.SIGTERM, shutdown)

# ── Mula ──────────────────────────────────────────────────────
if __name__ == "__main__":
    gpio.test_all()
    camera.start()
    logger.info(f"Flask API berjalan pada port {FLASK_PORT}")
    app.run(host="0.0.0.0", port=FLASK_PORT, threaded=True, use_reloader=False)
