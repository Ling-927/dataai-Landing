# ParkingGuard — Sistem Pengawasan Kenderaan Pintar

Sistem keselamatan kenderaan berasaskan AI menggunakan Raspberry Pi 4 + Pi Camera V3.

## Ciri-ciri

- **Pengenalan Plat** — YOLOv8 + EasyOCR (82.5% ketepatan siang hari)
- **Pengenalan Muka** — dlib face_recognition sebagai lapisan keselamatan kedua
- **Pengesanan Warna & Jenis Kenderaan** — YOLOv8 + analisis warna BGR
- **Senarai Putih** — Urus plat dibenarkan melalui web/mobile
- **Amaran GPIO** — Buzzer + LED merah berkelip
- **Notifikasi WhatsApp** — Twilio API dengan gambar kejadian
- **Papan Pemuka Web** — React.js + Tailwind CSS
- **Aplikasi Mobile** — React Native (Expo) untuk Android/iOS
- **Masa Nyata** — WebSocket untuk notifikasi segera

## Struktur Projek

```
parking-guard/
├── raspberry-pi/      # Kod Pi (kamera + GPIO)
├── backend/           # FastAPI server + AI pipeline
├── frontend/          # React.js web dashboard
├── mobile/            # React Native mobile app
├── scripts/           # Skrip setup dan muat turun model
├── docs/              # Laporan Projek Akhir DKM
└── docker-compose.yml
```

## Pemasangan Pantas

### 1. Backend Server

```bash
cd backend
cp .env.example .env
# Edit .env dengan credentials Twilio anda
pip install -r requirements.txt
uvicorn app.main:app --reload
```

### 2. Web Dashboard

```bash
cd frontend
npm install
REACT_APP_API_URL=http://localhost:8000 npm start
```

### 3. Raspberry Pi

```bash
# Pada Raspberry Pi
cp raspberry-pi/.env.example raspberry-pi/.env
# Edit BACKEND_URL=http://SERVER_IP:8000
bash scripts/setup_pi.sh
```

### 4. Docker (Semua sekaligus)

```bash
cd backend && cp .env.example .env  # edit .env dulu
docker-compose up -d
```

## Perkakasan

| Komponen | GPIO/Pin |
|---|---|
| Buzzer | GPIO 18 (via transistor BC547) |
| LED Merah | GPIO 23 (via 220Ω) |
| LED Hijau | GPIO 24 (via 220Ω) |
| Pi Camera V3 | CSI port |

## Konfigurasi Twilio WhatsApp

1. Daftar di [twilio.com](https://twilio.com)
2. Join sandbox: hantar `join [kod]` ke WhatsApp +14155238886
3. Isi `TWILIO_ACCOUNT_SID`, `TWILIO_AUTH_TOKEN`, `OWNER_WHATSAPP` dalam `.env`

## Laporan DKM

Lihat `docs/LAPORAN_PROJEK_AKHIR_DKM.md` untuk laporan projek akhir lengkap dalam format DKM Politeknik Malaysia.

## Teknologi

- **AI**: YOLOv8n, EasyOCR, face_recognition (dlib)
- **Backend**: FastAPI, SQLAlchemy, SQLite, WebSocket
- **Frontend**: React.js, TypeScript, Tailwind CSS, React Query
- **Mobile**: React Native (Expo)
- **Hardware**: Raspberry Pi 4 8GB, Pi Camera V3, RPi.GPIO
- **Notifikasi**: Twilio WhatsApp API
