#!/usr/bin/env python3
"""
Uji Pi Camera V3 — tangkap gambar dan simpan sebagai test_capture.jpg
Jalankan: python3 test_camera.py
"""
import sys
import time

print("=== Ujian Pi Camera V3 ===\n")

# Cuba picamera2 dahulu
try:
    from picamera2 import Picamera2
    print("→ Menggunakan picamera2...")
    cam = Picamera2()
    cfg = cam.create_still_configuration(main={"size": (1920, 1080)})
    cam.configure(cfg)
    cam.start()
    time.sleep(2)
    cam.capture_file("/home/pi/parking-guard/test_capture.jpg")
    cam.stop()
    print("✓ Gambar disimpan: /home/pi/parking-guard/test_capture.jpg")
    print("\nUkuran fail:")
    import os
    size = os.path.getsize("/home/pi/parking-guard/test_capture.jpg")
    print(f"  {size/1024:.1f} KB")

    # Tunjukkan info asas
    from PIL import Image
    img = Image.open("/home/pi/parking-guard/test_capture.jpg")
    print(f"  Resolusi: {img.size[0]}x{img.size[1]}")
    print("\n✓ Kamera berfungsi dengan baik!")

except ImportError:
    print("picamera2 tidak tersedia, cuba OpenCV...")
    import cv2
    cap = cv2.VideoCapture(0)
    if not cap.isOpened():
        print("✗ Tiada kamera dikesan!")
        sys.exit(1)
    ret, frame = cap.read()
    if ret:
        cv2.imwrite("/home/pi/parking-guard/test_capture.jpg", frame)
        print(f"✓ Gambar disimpan (OpenCV): {frame.shape[1]}x{frame.shape[0]}")
    cap.release()

except Exception as e:
    print(f"✗ Ralat kamera: {e}")
    print("\nSemak:")
    print("  - Kamera tersambung ke port CSI")
    print("  - Kamera diaktifkan: sudo raspi-config → Interface Options → Camera")
    print("  - Jalankan: libcamera-still -o test.jpg")
    sys.exit(1)
