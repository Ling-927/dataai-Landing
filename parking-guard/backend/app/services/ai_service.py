"""
AI recognition service: license plate, vehicle classification, face recognition.
Uses YOLOv8 for detection, EasyOCR for plate text, face_recognition for face matching.
"""
import cv2
import numpy as np
import pickle
import os
import logging
from pathlib import Path
from typing import Optional, Tuple
from dataclasses import dataclass, field

logger = logging.getLogger(__name__)


@dataclass
class PlateResult:
    plate_number: str
    confidence: float
    bbox: list = field(default_factory=list)


@dataclass
class VehicleResult:
    make: str
    model: str
    color: str
    confidence: float
    bbox: list = field(default_factory=list)


@dataclass
class FaceResult:
    name: str
    confidence: float
    is_owner: bool = False


@dataclass
class RecognitionResult:
    plate: Optional[PlateResult] = None
    vehicle: Optional[VehicleResult] = None
    faces: list = field(default_factory=list)
    is_whitelisted: bool = False
    owner_face_detected: bool = False
    raw_image_path: Optional[str] = None


VEHICLE_COLORS = {
    "white": ([200, 200, 200], [255, 255, 255]),
    "black": ([0, 0, 0], [50, 50, 50]),
    "silver": ([150, 150, 150], [200, 200, 200]),
    "red": ([150, 0, 0], [255, 80, 80]),
    "blue": ([0, 0, 150], [80, 80, 255]),
    "grey": ([80, 80, 80], [149, 149, 149]),
    "yellow": ([200, 200, 0], [255, 255, 100]),
    "green": ([0, 100, 0], [80, 200, 80]),
    "brown": ([80, 40, 0], [160, 100, 60]),
    "orange": ([200, 100, 0], [255, 160, 80]),
}


class AIService:
    def __init__(self, yolo_model_path: str, face_encodings_path: str):
        self.yolo_model = None
        self.ocr_reader = None
        self.face_encodings: dict = {}
        self.face_names: list = []
        self.known_encodings: list = []

        self._load_yolo(yolo_model_path)
        self._load_ocr()
        self._load_face_encodings(face_encodings_path)

    def _load_yolo(self, model_path: str):
        try:
            from ultralytics import YOLO
            if Path(model_path).exists():
                self.yolo_model = YOLO(model_path)
            else:
                self.yolo_model = YOLO("yolov8n.pt")
            logger.info("YOLO model loaded")
        except Exception as e:
            logger.error(f"YOLO load failed: {e}")

    def _load_ocr(self):
        try:
            import easyocr
            self.ocr_reader = easyocr.Reader(["en"], gpu=False)
            logger.info("EasyOCR loaded")
        except Exception as e:
            logger.error(f"EasyOCR load failed: {e}")

    def _load_face_encodings(self, path: str):
        if Path(path).exists():
            try:
                with open(path, "rb") as f:
                    data = pickle.load(f)
                self.known_encodings = data.get("encodings", [])
                self.face_names = data.get("names", [])
                self.owner_flags = data.get("is_owner", [])
                logger.info(f"Loaded {len(self.known_encodings)} face profiles")
            except Exception as e:
                logger.error(f"Face encodings load failed: {e}")

    def save_face_encodings(self, path: str):
        data = {
            "encodings": self.known_encodings,
            "names": self.face_names,
            "is_owner": getattr(self, "owner_flags", [False] * len(self.face_names)),
        }
        with open(path, "wb") as f:
            pickle.dump(data, f)

    def add_face(self, name: str, image_np: np.ndarray, is_owner: bool = False) -> bool:
        try:
            import face_recognition
            rgb = cv2.cvtColor(image_np, cv2.COLOR_BGR2RGB)
            encs = face_recognition.face_encodings(rgb)
            if not encs:
                return False
            self.known_encodings.append(encs[0])
            self.face_names.append(name)
            if not hasattr(self, "owner_flags"):
                self.owner_flags = []
            self.owner_flags.append(is_owner)
            return True
        except Exception as e:
            logger.error(f"Add face failed: {e}")
            return False

    def detect_plate(self, image_np: np.ndarray) -> Optional[PlateResult]:
        """Extract license plate text using EasyOCR on detected plate region."""
        if self.ocr_reader is None:
            return None
        try:
            gray = cv2.cvtColor(image_np, cv2.COLOR_BGR2GRAY)
            # Use YOLO to find plate region if available
            plate_img = self._crop_plate_region(image_np)
            results = self.ocr_reader.readtext(plate_img if plate_img is not None else gray)
            if not results:
                return None
            best = max(results, key=lambda x: x[2])
            text = best[1].upper().replace(" ", "").replace("-", "")
            if len(text) >= 3:
                return PlateResult(plate_number=text, confidence=float(best[2]))
        except Exception as e:
            logger.error(f"Plate detection error: {e}")
        return None

    def _crop_plate_region(self, image_np: np.ndarray) -> Optional[np.ndarray]:
        """Use YOLO or edge detection to find plate bounding box."""
        if self.yolo_model:
            try:
                results = self.yolo_model(image_np, classes=[0, 2, 3, 5, 7], verbose=False)
                for r in results:
                    for box in r.boxes:
                        if int(box.cls[0]) in [2, 3, 5, 7]:  # car/motorcycle/bus/truck
                            x1, y1, x2, y2 = map(int, box.xyxy[0])
                            region = image_np[y1:y2, x1:x2]
                            # Look for plate in bottom third of vehicle
                            h = region.shape[0]
                            return region[int(h * 0.6):, :]
            except Exception:
                pass
        return None

    def classify_vehicle(self, image_np: np.ndarray) -> Optional[VehicleResult]:
        """Classify vehicle make/model using YOLO and color analysis."""
        if self.yolo_model is None:
            return None
        try:
            results = self.yolo_model(image_np, verbose=False)
            vehicle_classes = {2: "Car", 3: "Motorcycle", 5: "Bus", 7: "Truck"}
            for r in results:
                for box in r.boxes:
                    cls = int(box.cls[0])
                    if cls in vehicle_classes:
                        x1, y1, x2, y2 = map(int, box.xyxy[0])
                        vehicle_crop = image_np[y1:y2, x1:x2]
                        color = self._detect_color(vehicle_crop)
                        conf = float(box.conf[0])
                        return VehicleResult(
                            make="Unknown",
                            model=vehicle_classes[cls],
                            color=color,
                            confidence=conf,
                            bbox=[x1, y1, x2, y2],
                        )
        except Exception as e:
            logger.error(f"Vehicle classify error: {e}")
        return None

    def _detect_color(self, image_np: np.ndarray) -> str:
        """Detect dominant vehicle color from cropped image."""
        try:
            if image_np.size == 0:
                return "unknown"
            h, w = image_np.shape[:2]
            center = image_np[h // 4: 3 * h // 4, w // 4: 3 * w // 4]
            avg = center.mean(axis=(0, 1))  # BGR
            b, g, r = int(avg[0]), int(avg[1]), int(avg[2])

            min_dist = float("inf")
            best_color = "unknown"
            for color_name, (low, high) in VEHICLE_COLORS.items():
                dist = ((r - (low[0] + high[0]) / 2) ** 2 +
                        (g - (low[1] + high[1]) / 2) ** 2 +
                        (b - (low[2] + high[2]) / 2) ** 2) ** 0.5
                if dist < min_dist:
                    min_dist = dist
                    best_color = color_name
            return best_color
        except Exception:
            return "unknown"

    def recognize_faces(self, image_np: np.ndarray) -> list:
        """Return list of FaceResult for detected faces."""
        results = []
        if not self.known_encodings:
            return results
        try:
            import face_recognition
            rgb = cv2.cvtColor(image_np, cv2.COLOR_BGR2RGB)
            locations = face_recognition.face_locations(rgb)
            encodings = face_recognition.face_encodings(rgb, locations)
            owner_flags = getattr(self, "owner_flags", [False] * len(self.face_names))

            for enc in encodings:
                distances = face_recognition.face_distance(self.known_encodings, enc)
                if len(distances) == 0:
                    continue
                idx = int(np.argmin(distances))
                confidence = float(1 - distances[idx])
                if confidence > 0.5:
                    results.append(FaceResult(
                        name=self.face_names[idx],
                        confidence=confidence,
                        is_owner=owner_flags[idx] if idx < len(owner_flags) else False,
                    ))
                else:
                    results.append(FaceResult(name="Unknown", confidence=confidence))
        except Exception as e:
            logger.error(f"Face recognition error: {e}")
        return results

    def analyze_frame(self, image_np: np.ndarray) -> RecognitionResult:
        """Full pipeline: plate + vehicle + face recognition."""
        result = RecognitionResult()
        result.plate = self.detect_plate(image_np)
        result.vehicle = self.classify_vehicle(image_np)
        result.faces = self.recognize_faces(image_np)
        result.owner_face_detected = any(f.is_owner and f.confidence > 0.6 for f in result.faces)
        return result
