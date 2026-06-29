#!/bin/bash
# Kemaskini fail ParkingGuard daripada server atau USB
# Jalankan: bash update.sh

PI_DIR="/home/pi/parking-guard"
VENV="  /home/pi/pg-venv"

echo "=== ParkingGuard Update ==="

# Semak sama ada ada fail baharu dalam USB
USB_MOUNT="/media/pi"
if ls "$USB_MOUNT"/*/parking-guard/ 2>/dev/null; then
    USB_SRC=$(ls -d "$USB_MOUNT"/*/parking-guard/ | head -1)
    echo "Jumpa pakej dalam USB: $USB_SRC"
    read -p "Kemaskini dari USB? [y/N]: " yn
    if [[ "$yn" =~ ^[Yy]$ ]]; then
        cp -r "$USB_SRC"/* "$PI_DIR/"
        chown -R pi:pi "$PI_DIR"
        echo "✓ Fail dikemaskini dari USB"
    fi
fi

# Kemaskini pakej Python
echo "→ Kemaskini pakej Python..."
source "/home/pi/pg-venv/bin/activate"
pip install -r "$PI_DIR/requirements.txt" --upgrade -q
echo "✓ Pakej dikemaskini"

# Restart servis
sudo systemctl restart parking-guard
sleep 2
if systemctl is-active --quiet parking-guard; then
    echo "✓ Servis berjalan semula"
else
    echo "✗ Servis gagal mula — semak: journalctl -u parking-guard -n 20"
fi
