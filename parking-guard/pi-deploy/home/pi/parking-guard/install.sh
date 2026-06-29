#!/bin/bash
# ================================================================
# I Defender — Skrip Pemasangan Automatik untuk Raspberry Pi 4
# Jalankan: sudo bash install.sh
# ================================================================

set -e
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; NC='\033[0m'

PI_DIR="/home/pi/parking-guard"
VENV_DIR="/home/pi/pg-venv"
SERVICE_FILE="/etc/systemd/system/parking-guard.service"
LOG_FILE="/home/pi/parking-guard-install.log"

log()  { echo -e "${GREEN}[✓]${NC} $1" | tee -a "$LOG_FILE"; }
info() { echo -e "${BLUE}[→]${NC} $1" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[!]${NC} $1" | tee -a "$LOG_FILE"; }
err()  { echo -e "${RED}[✗]${NC} $1" | tee -a "$LOG_FILE"; }
step() { echo -e "\n${CYAN}══════════════════════════════════════${NC}"; echo -e "${CYAN}  $1${NC}"; echo -e "${CYAN}══════════════════════════════════════${NC}"; }

echo "" | tee "$LOG_FILE"
echo -e "${BLUE}"
cat << 'BANNER'
 ____            _    _             ____                     _
|  _ \ __ _ _ __| | _(_)_ __   __ |  _ \ _   _  __ _ _ __ | |
| |_) / _` | '__| |/ / | '_ \ / _` | |_) | | | |/ _` | '__|| |
|  __/ (_| | |  |   <| | | | | (_| |  _ <| |_| | (_| | |   |_|
|_|   \__,_|_|  |_|\_\_|_| |_|\__, |_| \_\\__,_|\__,_|_|   (_)
                                |___/
     Sistem Pengawasan Kenderaan Pintar — Raspberry Pi 4
BANNER
echo -e "${NC}"

# Semak sama ada root
if [ "$EUID" -ne 0 ]; then
    err "Sila jalankan sebagai root: sudo bash install.sh"
    exit 1
fi

# Semak sama ada Raspberry Pi
if ! grep -q "Raspberry Pi" /proc/cpuinfo 2>/dev/null; then
    warn "Bukan Raspberry Pi — teruskan dalam mod simulasi?"
    read -p "Teruskan? [y/N]: " yn
    [[ "$yn" =~ ^[Yy]$ ]] || exit 1
fi

# ── Langkah 1: Kemas kini sistem ─────────────────────────────
step "LANGKAH 1/8: Kemas kini sistem"
info "apt-get update & upgrade (mungkin ambil 5-10 minit)..."
apt-get update -y >> "$LOG_FILE" 2>&1
apt-get upgrade -y >> "$LOG_FILE" 2>&1
log "Sistem dikemas kini"

# ── Langkah 2: Pasang kebergantungan sistem ───────────────────
step "LANGKAH 2/8: Pasang pakej sistem"
PKGS=(
    python3-pip python3-venv python3-dev
    python3-picamera2 libcamera-apps
    python3-opencv libopencv-dev
    libatlas-base-dev liblapack-dev libopenblas-dev
    libgpiod2 python3-lgpio
    git cmake build-essential
    ffmpeg libsm6 libxext6
    libcap-dev libjpeg-dev zlib1g-dev
    curl wget nano htop
)
for pkg in "${PKGS[@]}"; do
    info "Pasang: $pkg"
    apt-get install -y "$pkg" >> "$LOG_FILE" 2>&1 || warn "$pkg gagal (mungkin tidak kritikal)"
done
log "Pakej sistem dipasang"

# ── Langkah 3: Aktifkan antara muka ──────────────────────────
step "LANGKAH 3/8: Aktifkan kamera & GPIO"
raspi-config nonint do_camera 0    >> "$LOG_FILE" 2>&1 || true
raspi-config nonint do_i2c 0       >> "$LOG_FILE" 2>&1 || true
raspi-config nonint do_spi 0       >> "$LOG_FILE" 2>&1 || true
raspi-config nonint do_ssh 0       >> "$LOG_FILE" 2>&1 || true

# Pastikan gpu_mem=128 dalam config.txt
if ! grep -q "gpu_mem=128" /boot/config.txt 2>/dev/null; then
    echo "gpu_mem=128" >> /boot/config.txt
fi
if ! grep -q "camera_auto_detect" /boot/config.txt 2>/dev/null; then
    echo "camera_auto_detect=1" >> /boot/config.txt
    echo "dtoverlay=camera,cam0" >> /boot/config.txt
fi
log "Kamera, GPIO, I2C, SPI, SSH diaktifkan"

# ── Langkah 4: Wujudkan Python venv ──────────────────────────
step "LANGKAH 4/8: Wujudkan persekitaran Python"
if [ -d "$VENV_DIR" ]; then
    warn "venv sedia ada — padam dan buat semula"
    rm -rf "$VENV_DIR"
fi
python3 -m venv "$VENV_DIR" --system-site-packages
source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel >> "$LOG_FILE" 2>&1
log "Python venv siap: $VENV_DIR"

# ── Langkah 5: Pasang pakej Python ───────────────────────────
step "LANGKAH 5/8: Pasang pakej Python (mungkin 5-15 minit)"
pip install -r "$PI_DIR/requirements.txt" >> "$LOG_FILE" 2>&1
log "Pakej Python dipasang"

# ── Langkah 6: Tetapkan kebenaran ────────────────────────────
step "LANGKAH 6/8: Tetapkan kebenaran"
chown -R pi:pi "$PI_DIR"
chown -R pi:pi "$VENV_DIR"
chmod +x "$PI_DIR/main.py"
chmod +x "$PI_DIR/install.sh"
usermod -aG gpio,video,i2c,spi pi >> "$LOG_FILE" 2>&1 || true
log "Kebenaran ditetapkan"

# ── Langkah 7: Wujudkan systemd service ──────────────────────
step "LANGKAH 7/8: Wujudkan servis auto-start"
cat > "$SERVICE_FILE" << SVCEOF
[Unit]
Description=I Defender Pi - Sistem Pengawasan Kenderaan
After=network-online.target
Wants=network-online.target
StartLimitIntervalSec=0

[Service]
Type=simple
User=pi
Group=pi
WorkingDirectory=$PI_DIR
Environment="PATH=$VENV_DIR/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin"
ExecStartPre=/bin/sleep 5
ExecStart=$VENV_DIR/bin/python3 $PI_DIR/main.py
Restart=always
RestartSec=10
StandardOutput=journal
StandardError=journal
SyslogIdentifier=parking-guard

[Install]
WantedBy=multi-user.target
SVCEOF

systemctl daemon-reload
systemctl enable parking-guard
log "Servis parking-guard diaktifkan (auto-start semasa boot)"

# ── Langkah 8: Konfigurasi ────────────────────────────────────
step "LANGKAH 8/8: Konfigurasi sistem"

# Wizard konfigurasi
echo ""
echo -e "${YELLOW}=== WIZARD KONFIGURASI ===${NC}"
echo ""

# IP Backend
CURRENT_BACKEND=$(grep "BACKEND_URL" "$PI_DIR/config.env" | cut -d= -f2)
echo -e "IP semasa backend: ${CYAN}$CURRENT_BACKEND${NC}"
read -p "Masukkan IP server backend anda (contoh: http://192.168.1.100:8000) [Enter untuk skip]: " NEW_BACKEND
if [ -n "$NEW_BACKEND" ]; then
    sed -i "s|BACKEND_URL=.*|BACKEND_URL=$NEW_BACKEND|" "$PI_DIR/config.env"
    log "Backend URL dikemaskini: $NEW_BACKEND"
fi

# Nama Zon
CURRENT_ZONE=$(grep "^ZONE=" "$PI_DIR/config.env" | cut -d= -f2)
echo -e "Nama zon semasa: ${CYAN}$CURRENT_ZONE${NC}"
read -p "Nama zon kamera ini (contoh: driveway/front/gate) [Enter untuk skip]: " NEW_ZONE
if [ -n "$NEW_ZONE" ]; then
    sed -i "s|^ZONE=.*|ZONE=$NEW_ZONE|" "$PI_DIR/config.env"
    log "Zon dikemaskini: $NEW_ZONE"
fi

# ── Ujian GPIO ────────────────────────────────────────────────
echo ""
read -p "Uji Buzzer + LED sekarang? [y/N]: " TEST_GPIO
if [[ "$TEST_GPIO" =~ ^[Yy]$ ]]; then
    info "Menguji GPIO..."
    sudo -u pi "$VENV_DIR/bin/python3" -c "
import sys; sys.path.insert(0, '$PI_DIR')
from gpio.controller import GPIOController
import time
g = GPIOController()
g.test_all()
print('Ujian GPIO selesai')
" && log "GPIO berfungsi dengan baik" || warn "Ujian GPIO gagal — semak pendawaian"
fi

# ── Mula servis ───────────────────────────────────────────────
echo ""
read -p "Mulakan servis sekarang? [Y/n]: " START_NOW
if [[ ! "$START_NOW" =~ ^[Nn]$ ]]; then
    systemctl start parking-guard
    sleep 3
    if systemctl is-active --quiet parking-guard; then
        log "Servis parking-guard berjalan!"
    else
        warn "Servis gagal mula — semak log: journalctl -u parking-guard -f"
    fi
fi

# ── Selesai ───────────────────────────────────────────────────
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║         PEMASANGAN BERJAYA! ✓                ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════════╝${NC}"
echo ""
echo -e "📁 Direktori   : ${CYAN}$PI_DIR${NC}"
echo -e "📋 Log fail    : ${CYAN}$PI_DIR/idefender.log${NC}"
echo -e "🔧 Konfigurasi : ${CYAN}$PI_DIR/config.env${NC}"
echo ""
echo -e "${YELLOW}Arahan berguna:${NC}"
echo -e "  Semak status  : ${CYAN}sudo systemctl status parking-guard${NC}"
echo -e "  Tengok log    : ${CYAN}journalctl -u parking-guard -f${NC}"
echo -e "  Mulakan       : ${CYAN}sudo systemctl start parking-guard${NC}"
echo -e "  Hentikan      : ${CYAN}sudo systemctl stop parking-guard${NC}"
echo -e "  Edit config   : ${CYAN}nano $PI_DIR/config.env${NC}"
echo -e "  Restart       : ${CYAN}sudo systemctl restart parking-guard${NC}"
echo ""
echo -e "${YELLOW}⚠️  REBOOT DIPERLUKAN untuk kamera aktif sepenuhnya!${NC}"
echo ""
read -p "Reboot sekarang? [y/N]: " REBOOT_NOW
[[ "$REBOOT_NOW" =~ ^[Yy]$ ]] && reboot
