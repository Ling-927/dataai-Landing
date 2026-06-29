# PANDUAN LENGKAP — SALIN KE microSD & PASANG KE RASPBERRY PI 4

---

## SENARAI SEMAK PERKAKASAN

Pastikan anda ada semua ini sebelum mulakan:

| Item | Spesifikasi | Keperluan |
|---|---|---|
| Raspberry Pi 4 | 8GB RAM | **WAJIB** |
| Pi Camera V3 | 12MP, autofokus | **WAJIB** |
| MicroSD | 32GB+ (Class 10 / U3) | **WAJIB** |
| Kabel CSI | Kabel ribbon 15-pin (biasanya ikut kamera) | **WAJIB** |
| Bekalan kuasa | USB-C, 5V/3A (minimum) | **WAJIB** |
| Buzzer aktif | 5V | **WAJIB** |
| LED Merah + Hijau | 5mm, 20mA | **WAJIB** |
| Rintangan 220Ω | 2 keping | **WAJIB** |
| Transistor BC547 | NPN | **WAJIB** |
| Rintangan 1kΩ | 1 keping | **WAJIB** |
| Papan roti + wayar | - | Disyorkan |

---

## BAHAGIAN 1 — FLASH OS KE microSD

### Langkah 1.1: Muat turun Raspberry Pi Imager

Pergi ke: **https://www.raspberrypi.com/software/**

Muat turun mengikut OS komputer anda:
- Windows → Raspberry Pi Imager for Windows
- Mac → Raspberry Pi Imager for macOS
- Linux → `sudo apt install rpi-imager`

### Langkah 1.2: Flash OS

1. Buka **Raspberry Pi Imager**
2. Klik **"Choose Device"** → Pilih **Raspberry Pi 4**
3. Klik **"Choose OS"** → **Raspberry Pi OS (other)** → **Raspberry Pi OS Lite (64-bit)**
   > ⚠️ Pilih **64-bit** untuk prestasi AI lebih baik
4. Klik **"Choose Storage"** → Pilih kad microSD anda
5. Klik ikon **gear ⚙️** (Advanced Options) — **PENTING!**
   ```
   ✓ Set hostname: raspberrypi
   ✓ Enable SSH: Use password authentication
   ✓ Set username: pi
   ✓ Set password: [KATA LALUAN ANDA - simpan baik-baik!]
   ✓ Configure wireless LAN:
       SSID: [NAMA WIFI ANDA]
       Password: [PASSWORD WIFI ANDA]
       Country: MY
   ✓ Set locale: Asia/Kuala_Lumpur
   ```
6. Klik **"Write"** dan tunggu sehingga selesai (~5-10 minit)

---

## BAHAGIAN 2 — SALIN FAIL PARKINGGUARD KE microSD

Selepas flash selesai, **JANGAN keluarkan** kad microSD.

Pada Windows: kad akan muncul sebagai 2 drive:
- `boot` (partition kecil)
- `rootfs` atau `ext4` (partition besar — mungkin tidak nampak pada Windows)

> **Nota Windows:** Windows tidak boleh baca partition `ext4` secara terus.
> Gunakan kaedah di bawah mengikut OS anda.

---

### KAEDAH A: Windows (Guna Rufus / Linux Subsystem)

**Cara paling mudah: salin ke partition boot sahaja, kemudian setup melalui SSH**

1. Buka drive `boot` yang muncul di Windows Explorer
2. **Salin** semua fail dari folder `pi-deploy/boot/` ke dalam drive `boot`:
   ```
   Salin ke D:\boot\ (gantikan D dengan huruf drive anda):
   ├── wpa_supplicant.conf   ← WiFi credentials
   ├── ssh                   ← Aktifkan SSH (fail kosong)
   └── config.txt            ← Konfigurasi Pi
   ```
3. Buka `wpa_supplicant.conf` dengan Notepad dan **edit**:
   ```
   ssid="NAMA_WIFI_ANDA"     ← Tukar kepada nama WiFi anda
   psk="PASSWORD_WIFI_ANDA"  ← Tukar kepada password WiFi anda
   ```
4. Keluarkan microSD dengan selamat (klik kanan → Eject)

---

### KAEDAH B: macOS / Linux (Cara Lengkap)

```bash
# 1. Semak nama disk microSD
diskutil list            # macOS
# atau
lsblk                    # Linux

# 2. Mount partition rootfs
# macOS: install ext4fuse
brew install ext4fuse
sudo ext4fuse /dev/disk2s2 /mnt/rootfs -o allow_other

# Linux (partition sudah auto-mount):
# biasanya di /media/USER/rootfs

# 3. Salin folder parking-guard
sudo cp -r pi-deploy/home/pi/parking-guard /mnt/rootfs/home/pi/
sudo chown -R 1000:1000 /mnt/rootfs/home/pi/parking-guard

# 4. Salin fail boot
sudo cp pi-deploy/boot/wpa_supplicant.conf /mnt/rootfs/boot/
sudo cp pi-deploy/boot/ssh /mnt/rootfs/boot/
# Edit config.txt jika perlu
```

---

### KAEDAH C: Setup Terus via SSH (PALING DISYORKAN)

Cara ini paling mudah — salin ke Pi terus selepas boot pertama:

```
1. Flash microSD (ikut Langkah 1.1 & 1.2 di atas dengan Advanced Options)
2. Pasang microSD ke Pi, sambung bekalan kuasa
3. Tunggu 2-3 minit untuk Pi boot
4. Cari IP address Pi di router anda
5. SSH ke Pi:
   ssh pi@192.168.1.XXX
6. Jalankan arahan setup di bawah
```

---

## BAHAGIAN 3 — SETUP MELALUI SSH

### Langkah 3.1: Cari IP Raspberry Pi

Pilih mana-mana cara:
- **Router admin page** — biasanya 192.168.1.1 atau 192.168.0.1
- **Network scanner** — muat turun `Advanced IP Scanner` (Windows) atau `nmap` (Linux/Mac)
- **Dari Pi terus** (jika ada monitor): `hostname -I`

### Langkah 3.2: Sambung SSH

```bash
# Windows: guna PowerShell atau PuTTY
ssh pi@192.168.1.XXX

# Mac/Linux: guna Terminal
ssh pi@192.168.1.XXX

# Kata laluan: yang anda tetapkan semasa flash
# atau 'raspberry' jika pakai default
```

### Langkah 3.3: Hantar fail ke Pi

Dari komputer anda (bukan dari Pi), jalankan:

```bash
# Dari Windows PowerShell (gantikan 192.168.1.XXX dengan IP Pi anda):
scp -r parking-guard/pi-deploy/home/pi/parking-guard pi@192.168.1.XXX:/home/pi/

# Dari Mac/Linux Terminal:
scp -r parking-guard/pi-deploy/home/pi/parking-guard pi@192.168.1.XXX:/home/pi/
```

### Langkah 3.4: Jalankan skrip pemasangan automatik

```bash
# Dari dalam SSH Pi:
cd /home/pi/parking-guard
sudo bash install.sh
```

Skrip ini akan:
- ✅ Kemas kini sistem
- ✅ Pasang semua pakej
- ✅ Aktifkan kamera, GPIO, I2C, SPI
- ✅ Buat Python virtual environment
- ✅ Pasang semua library Python
- ✅ Tetapkan systemd service (auto-start)
- ✅ Jalankan wizard konfigurasi
- ✅ Uji GPIO (opsional)
- ✅ Reboot (opsional)

---

## BAHAGIAN 4 — PENDAWAIAN PERKAKASAN

### Rajah Pendawaian Lengkap

```
RASPBERRY PI 4 — GPIO HEADER (40-pin)
===========================================

  3.3V  [Pin 1 ] ●─────────────────────────────
    5V  [Pin 2 ] ●──┬───────────────────────────── (+) Buzzer
    5V  [Pin 4 ] ●──┘
   GND  [Pin 6 ] ●──────┬──────────────────────── GND semua
   GND  [Pin 9 ] ●──────┤
   GND  [Pin 14] ●──────┤
  GPIO18[Pin 12] ●──[1kΩ]──► Base BC547
  GPIO23[Pin 16] ●──[220Ω]──► LED MERAH (+)
  GPIO24[Pin 18] ●──[220Ω]──► LED HIJAU (+)

TRANSISTOR BC547:
  Base      ← GPIO18 via 1kΩ
  Collector ← Buzzer (-)
  Emitter   ← GND

LED:
  LED MERAH (+) ← GPIO23 via 220Ω | (-) → GND
  LED HIJAU (+) ← GPIO24 via 220Ω | (-) → GND

PI CAMERA V3:
  Kabel CSI ribbon → Port kamera Pi (berhampiran port HDMI)
  Kunci latch hitam → Tarik ke atas sebelum masuk ribbon
```

### Gambarajah Visual

```
         ┌─────────────────────────────────────────┐
         │         RASPBERRY Pi 4                  │
         │                                         │
         │  [USB-C Power]  [HDMI] [USB] [ETH]      │
         │                                         │
    ┌────┤ GPIO Header                             │
    │    │ ●● [1,2]  3.3V / 5V                    │
    │    │ ●● [3,4]  GPIO2 / 5V                   │
    │    │ ●● [5,6]  GPIO3 / GND ────────── GND   │
    │    │ ●● [7,8]                                │
    │    │ ●● [9,10] GND / GPIO15                  │
    │    │ ●● [11,12] GPIO17 / GPIO18 ─── Buzzer   │
    │    │ ●● [13,14]                              │
    │    │ ●● [15,16] GPIO22 / GPIO23 ── LED Merah │
    │    │ ●● [17,18] 3.3V / GPIO24 ─── LED Hijau  │
    │    └─────────────────────────────────────────┘
    │
    └── CSI ──► [Pi Camera V3]
```

---

## BAHAGIAN 5 — KONFIGURASI SELEPAS PASANG

### Edit konfigurasi

```bash
nano /home/pi/parking-guard/config.env
```

Tukar nilai-nilai ini:

```bash
BACKEND_URL=http://192.168.1.100:8000   # IP server anda
ZONE=driveway                            # Nama zon kamera
CAPTURE_INTERVAL=2.0                     # Selang (saat)
```

### Semak log

```bash
# Log servis (masa nyata)
journalctl -u parking-guard -f

# Log fail
tail -f /home/pi/parking-guard/idefender.log
```

### Arahan berguna

```bash
sudo systemctl start parking-guard     # Mulakan
sudo systemctl stop parking-guard      # Hentikan
sudo systemctl restart parking-guard   # Restart
sudo systemctl status parking-guard    # Semak status

# Uji GPIO sahaja
python3 /home/pi/parking-guard/scripts/test_gpio.py

# Uji kamera sahaja
python3 /home/pi/parking-guard/scripts/test_camera.py

# Uji sambungan backend
python3 /home/pi/parking-guard/scripts/test_backend.py
```

---

## BAHAGIAN 6 — PENYELESAIAN MASALAH

| Masalah | Sebab | Penyelesaian |
|---|---|---|
| Kamera tidak dikesan | Kabel tidak betul / tidak diaktifkan | `sudo raspi-config` → Interface → Camera |
| GPIO tidak berfungsi | Pengguna bukan dalam group gpio | `sudo usermod -aG gpio pi` |
| Servis tidak mula | Ralat Python | `journalctl -u parking-guard -n 50` |
| Tidak dapat sambung backend | IP salah atau firewall | Semak `config.env` dan firewall server |
| LED tidak menyala | Rintangan/pendawaian salah | Semak dengan `test_gpio.py` |
| Buzzer tidak berbunyi | Transistor tidak betul | Semak orientasi BC547 (EBC) |
| picamera2 tidak tersedia | Library tidak dipasang | `pip install picamera2` dalam venv |

---

## NOTA PENTING

> 📌 **WiFi Malaysia**: Pastikan `country=MY` dalam `wpa_supplicant.conf`

> 📌 **Keselamatan**: Tukar kata laluan default Pi segera selepas setup

> 📌 **Backup**: Simpan salinan `config.env` di tempat selamat

> 📌 **Kemas kini**: Jalankan `bash /home/pi/parking-guard/scripts/update.sh` untuk kemaskini

---

*I Defender v1.0 — Sistem Pengawasan Kenderaan Pintar*
*Raspberry Pi 4 8GB + Pi Camera V3 + Buzzer + LED*
