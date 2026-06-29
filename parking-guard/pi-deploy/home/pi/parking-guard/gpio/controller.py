"""
GPIO controller untuk Raspberry Pi 4 - ParkingGuard
Buzzer  → GPIO 18 (BCM) via transistor BC547
LED Merah → GPIO 23 (BCM) via 220Ω
LED Hijau → GPIO 24 (BCM) via 220Ω

Wiring:
  Pi GPIO18 → 1kΩ → Base BC547
  BC547 Collector → Buzzer (-) → Buzzer (+) → 5V
  BC547 Emitter → GND
  Pi GPIO23 → 220Ω → LED Merah (+) → GND
  Pi GPIO24 → 220Ω → LED Hijau (+) → GND
"""
import time
import threading
import logging

logger = logging.getLogger(__name__)

BUZZER_PIN   = 18
LED_RED_PIN  = 23
LED_GREEN_PIN = 24

try:
    import RPi.GPIO as GPIO
    GPIO.setmode(GPIO.BCM)
    GPIO.setwarnings(False)
    GPIO.setup(BUZZER_PIN,    GPIO.OUT, initial=GPIO.LOW)
    GPIO.setup(LED_RED_PIN,   GPIO.OUT, initial=GPIO.LOW)
    GPIO.setup(LED_GREEN_PIN, GPIO.OUT, initial=GPIO.LOW)
    GPIO_AVAILABLE = True
    logger.info("GPIO berjaya diinisialisasi")
except Exception as e:
    GPIO_AVAILABLE = False
    logger.warning(f"GPIO tidak tersedia (simulasi mod): {e}")


def _pin(pin, state):
    if GPIO_AVAILABLE:
        import RPi.GPIO as GPIO
        GPIO.output(pin, GPIO.HIGH if state else GPIO.LOW)
    else:
        logger.debug(f"[SIM] GPIO {pin} → {'HIGH' if state else 'LOW'}")


class GPIOController:
    def __init__(self):
        self._lock = threading.Lock()
        self._running = False

    def trigger_alert(self, duration: float = 10.0):
        """Buzzer beep + LED merah berkelip selama `duration` saat."""
        threading.Thread(
            target=self._alert_loop,
            args=(duration,),
            daemon=True
        ).start()

    def _alert_loop(self, duration: float):
        with self._lock:
            self._running = True
            _pin(LED_GREEN_PIN, False)
            deadline = time.time() + duration
            logger.info(f"Alert aktif selama {duration}s")
            while time.time() < deadline and self._running:
                _pin(BUZZER_PIN,  True)
                _pin(LED_RED_PIN, True)
                time.sleep(0.4)
                _pin(BUZZER_PIN,  False)
                _pin(LED_RED_PIN, False)
                time.sleep(0.4)
            self._all_off()
            self._running = False
            self.set_ready()

    def set_ready(self):
        """LED hijau = sistem sedia."""
        self._running = False
        _pin(BUZZER_PIN,  False)
        _pin(LED_RED_PIN, False)
        _pin(LED_GREEN_PIN, True)
        logger.info("Sistem sedia (LED hijau ON)")

    def stop_alert(self):
        self._running = False
        self._all_off()
        self.set_ready()

    def _all_off(self):
        _pin(BUZZER_PIN,   False)
        _pin(LED_RED_PIN,  False)
        _pin(LED_GREEN_PIN, False)

    def test_all(self):
        """Uji semua komponen GPIO — panggil semasa startup."""
        logger.info("Ujian GPIO: Buzzer + LED Merah + LED Hijau")
        for pin in [LED_GREEN_PIN, LED_RED_PIN]:
            _pin(pin, True)
            time.sleep(0.3)
            _pin(pin, False)
        _pin(BUZZER_PIN, True)
        time.sleep(0.2)
        _pin(BUZZER_PIN, False)
        time.sleep(0.5)
        self.set_ready()

    def cleanup(self):
        self._all_off()
        if GPIO_AVAILABLE:
            import RPi.GPIO as GPIO
            GPIO.cleanup()
