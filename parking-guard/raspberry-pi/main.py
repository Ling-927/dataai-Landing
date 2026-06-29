"""
Raspberry Pi main entry point.
Runs Flask API for GPIO control + camera capture loop.
"""
import os
import signal
import logging
import threading
from dotenv import load_dotenv
from flask import Flask, request, jsonify

load_dotenv()
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

BACKEND_URL = os.getenv("BACKEND_URL", "http://localhost:8000")
ZONE = os.getenv("ZONE", "driveway")
CAPTURE_INTERVAL = float(os.getenv("CAPTURE_INTERVAL", "2.0"))

from gpio.controller import GPIOController
from camera.capture import CameraCapture

gpio = GPIOController()
camera = CameraCapture(backend_url=BACKEND_URL, zone=ZONE, interval=CAPTURE_INTERVAL)

app = Flask(__name__)


@app.route("/health")
def health():
    return jsonify({"status": "ok", "zone": ZONE})


@app.route("/alert/trigger", methods=["POST"])
def trigger_alert():
    data = request.get_json(silent=True) or {}
    duration = float(data.get("duration", 10))
    gpio.trigger_alert(duration=duration)
    logger.info(f"Alert triggered for {duration}s")
    return jsonify({"message": "alert triggered", "duration": duration})


@app.route("/alert/stop", methods=["POST"])
def stop_alert():
    gpio.stop_alert()
    return jsonify({"message": "alert stopped"})


@app.route("/gpio/ready", methods=["POST"])
def set_ready():
    gpio.set_ready()
    return jsonify({"message": "ready"})


def shutdown(sig, frame):
    logger.info("Shutting down...")
    camera.stop()
    gpio.cleanup()
    raise SystemExit(0)


if __name__ == "__main__":
    signal.signal(signal.SIGINT, shutdown)
    signal.signal(signal.SIGTERM, shutdown)

    gpio.set_ready()
    camera.start()
    logger.info(f"ParkingGuard Pi running. Backend: {BACKEND_URL}")
    app.run(host="0.0.0.0", port=5000, threaded=True)
