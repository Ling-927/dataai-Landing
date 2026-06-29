#!/usr/bin/env python3
"""
Uji sambungan ke backend server
Jalankan: python3 test_backend.py
"""
import sys
import os
sys.path.insert(0, "/home/pi/parking-guard")
from dotenv import load_dotenv
load_dotenv("/home/pi/parking-guard/config.env")

import requests

BACKEND = os.getenv("BACKEND_URL", "http://192.168.1.100:8000")

print(f"=== Ujian Sambungan Backend ===")
print(f"URL: {BACKEND}\n")

# Health check
try:
    r = requests.get(f"{BACKEND}/health", timeout=5)
    if r.status_code == 200:
        print(f"✓ Backend boleh dicapai: {r.json()}")
    else:
        print(f"✗ Backend balas {r.status_code}")
        sys.exit(1)
except requests.ConnectionError:
    print(f"✗ Tidak dapat sambung ke {BACKEND}")
    print("\nSemak:")
    print("  - Backend server sedang berjalan")
    print(f"  - Pi dan server dalam rangkaian yang sama")
    print(f"  - Firewall membenarkan port 8000")
    print(f"  - BACKEND_URL dalam config.env betul")
    sys.exit(1)

# Test analyze endpoint dengan imej dummy
print("\n→ Uji endpoint analisis...")
try:
    import io
    from PIL import Image, ImageDraw
    img = Image.new("RGB", (640, 480), color=(100, 100, 100))
    draw = ImageDraw.Draw(img)
    draw.rectangle([200, 350, 440, 420], fill=(255, 255, 255))
    draw.text((220, 365), "WXY 1234", fill=(0, 0, 0))
    buf = io.BytesIO()
    img.save(buf, format="JPEG")
    buf.seek(0)

    r = requests.post(
        f"{BACKEND}/api/events/analyze",
        files={"file": ("test.jpg", buf, "image/jpeg")},
        data={"zone": "test"},
        timeout=30,
    )
    if r.status_code in [200, 422, 401]:
        print(f"✓ Endpoint analisis boleh dicapai (status: {r.status_code})")
    else:
        print(f"! Endpoint balas {r.status_code}: {r.text[:200]}")
except Exception as e:
    print(f"! Ujian analisis gagal: {e}")

print("\n=== Ujian selesai ===")
