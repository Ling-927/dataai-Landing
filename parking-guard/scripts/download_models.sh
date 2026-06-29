#!/bin/bash
# Download AI models for ParkingGuard
set -e

mkdir -p ai-models
cd ai-models

echo "Memuat turun YOLOv8n model..."
python3 -c "from ultralytics import YOLO; YOLO('yolov8n.pt')" && mv yolov8n.pt ai-models/ 2>/dev/null || true

echo "Model sedia di folder ai-models/"
echo "Nota: face_encodings.pkl akan dijana secara automatik apabila mendaftar muka pertama."
