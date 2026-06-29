"""
GPIO controller for buzzer and LED on Raspberry Pi 4.

Wiring:
  Buzzer  → GPIO 18 (BCM) via transistor
  LED Red → GPIO 23 (BCM) via 220Ω resistor
  LED Green → GPIO 24 (BCM) via 220Ω resistor
  GND     → Pin 6 (Ground)
"""
import time
import threading
import logging

logger = logging.getLogger(__name__)

try:
    import RPi.GPIO as GPIO
    GPIO_AVAILABLE = True
except (ImportError, RuntimeError):
    GPIO_AVAILABLE = False
    logger.warning("RPi.GPIO not available — GPIO calls will be simulated")


BUZZER_PIN = 18
LED_RED_PIN = 23
LED_GREEN_PIN = 24


class GPIOController:
    def __init__(self):
        self._lock = threading.Lock()
        self._active = False
        if GPIO_AVAILABLE:
            GPIO.setmode(GPIO.BCM)
            GPIO.setwarnings(False)
            GPIO.setup(BUZZER_PIN, GPIO.OUT, initial=GPIO.LOW)
            GPIO.setup(LED_RED_PIN, GPIO.OUT, initial=GPIO.LOW)
            GPIO.setup(LED_GREEN_PIN, GPIO.OUT, initial=GPIO.LOW)
            logger.info("GPIO initialised")

    def _set_pin(self, pin: int, state: bool):
        if GPIO_AVAILABLE:
            GPIO.output(pin, GPIO.HIGH if state else GPIO.LOW)
        else:
            logger.debug(f"[SIMULATE] GPIO pin {pin} → {'HIGH' if state else 'LOW'}")

    def trigger_alert(self, duration: float = 10.0):
        """Non-blocking alert: buzzer beeps + red LED flashes for duration seconds."""
        threading.Thread(target=self._alert_sequence, args=(duration,), daemon=True).start()

    def _alert_sequence(self, duration: float):
        with self._lock:
            self._active = True
            self._set_pin(LED_GREEN_PIN, False)
            end_time = time.time() + duration
            while time.time() < end_time and self._active:
                self._set_pin(BUZZER_PIN, True)
                self._set_pin(LED_RED_PIN, True)
                time.sleep(0.5)
                self._set_pin(BUZZER_PIN, False)
                self._set_pin(LED_RED_PIN, False)
                time.sleep(0.5)
            self._all_off()
            self._active = False

    def set_ready(self):
        """Green LED on = system armed and ready."""
        with self._lock:
            self._active = False
            self._set_pin(BUZZER_PIN, False)
            self._set_pin(LED_RED_PIN, False)
            self._set_pin(LED_GREEN_PIN, True)

    def stop_alert(self):
        self._active = False
        self._all_off()
        self.set_ready()

    def _all_off(self):
        self._set_pin(BUZZER_PIN, False)
        self._set_pin(LED_RED_PIN, False)
        self._set_pin(LED_GREEN_PIN, False)

    def cleanup(self):
        self._all_off()
        if GPIO_AVAILABLE:
            GPIO.cleanup()
