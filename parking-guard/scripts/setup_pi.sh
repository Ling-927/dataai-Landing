#!/bin/bash
# Setup script for Raspberry Pi 4 - I Defender
set -e

echo "=== I Defender Pi Setup ==="

# Update system
sudo apt-get update && sudo apt-get upgrade -y

# Install system dependencies
sudo apt-get install -y python3-pip python3-venv git cmake \
    libopenblas-dev liblapack-dev libatlas-base-dev \
    python3-picamera2 libcap-dev ffmpeg

# Enable camera interface
echo "gpu_mem=128" | sudo tee -a /boot/config.txt
sudo raspi-config nonint do_camera 0

# Create venv
cd /home/pi
python3 -m venv idefender-env
source idefender-env/bin/activate

# Install Python deps
pip install --upgrade pip
pip install -r /home/pi/idefender/raspberry-pi/requirements-pi.txt

# Create systemd service
cat > /tmp/idefender.service << 'EOF'
[Unit]
Description=I Defender Pi Service
After=network.target

[Service]
Type=simple
User=pi
WorkingDirectory=/home/pi/idefender/raspberry-pi
Environment="PATH=/home/pi/idefender-env/bin"
ExecStart=/home/pi/idefender-env/bin/python main.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

sudo cp /tmp/idefender.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable idefender
sudo systemctl start idefender

echo "=== Setup selesai! ==="
echo "Semak status: sudo systemctl status parking-guard"
