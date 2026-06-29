#!/usr/bin/env python3
"""
Uji GPIO: Buzzer + LED Merah + LED Hijau
Jalankan: python3 test_gpio.py
"""
import sys
import time
sys.path.insert(0, "/home/pi/parking-guard")
from gpio.controller import GPIOController

print("=== Ujian GPIO ParkingGuard ===\n")

g = GPIOController()

print("1. Ujian LED Hijau (2 saat)...")
from gpio.controller import _pin, LED_GREEN_PIN, LED_RED_PIN, BUZZER_PIN
_pin(LED_GREEN_PIN, True)
time.sleep(2)
_pin(LED_GREEN_PIN, False)
print("   ✓ LED Hijau OK\n")

print("2. Ujian LED Merah (2 saat)...")
_pin(LED_RED_PIN, True)
time.sleep(2)
_pin(LED_RED_PIN, False)
print("   ✓ LED Merah OK\n")

print("3. Ujian Buzzer (3 bunyi pendek)...")
for i in range(3):
    _pin(BUZZER_PIN, True)
    time.sleep(0.2)
    _pin(BUZZER_PIN, False)
    time.sleep(0.2)
print("   ✓ Buzzer OK\n")

print("4. Ujian urutan amaran penuh (5 saat)...")
g.trigger_alert(duration=5)
time.sleep(6)
print("   ✓ Urutan amaran OK\n")

print("5. Set ke status SEDIA...")
g.set_ready()
time.sleep(1)
g.cleanup()

print("=== Semua ujian selesai! ===")
print("\nJika tiada bunyi/cahaya, semak:")
print("  - Pendawaian (GPIO 18=Buzzer, 23=LED Merah, 24=LED Hijau)")
print("  - Rintangan 220Ω untuk LED")
print("  - Transistor BC547 untuk Buzzer")
