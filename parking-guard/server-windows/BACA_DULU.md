# I DEFENDER — PANDUAN SETUP SERVER WINDOWS

## KEPERLUAN SISTEM

| Perisian | Minimum | Muat Turun |
|---|---|---|
| Windows | 10 / 11 (64-bit) | — |
| Python | 3.10 atau 3.11 | https://python.org/downloads |
| Node.js | 18 LTS atau 20 LTS | https://nodejs.org |
| Git | Terbaharu | https://git-scm.com (opsional) |

> ⚠️ **PENTING semasa pasang Python:** Tanda pada kotak **"Add Python to PATH"**

---

## URUTAN SETUP (IKUT TERTIB)

### Langkah 1 — Pasang keperluan
```
Double-click: 1_INSTALL.bat  (klik kanan → Run as administrator)
```
- Pasang semua library Python secara automatik
- Ambil masa 5–15 minit (kali pertama sahaja)

### Langkah 2 — Buka Firewall
```
Double-click: 5_OPEN_FIREWALL.bat  (klik kanan → Run as administrator)
```
- Buka port 8000 supaya Raspberry Pi boleh sambung

### Langkah 3 — Edit konfigurasi
```
Double-click: .env  (buka dengan Notepad)
```
Tukar baris ini:
```
OWNER_WHATSAPP=whatsapp:+60123456789  ← No. WhatsApp anda
TWILIO_ACCOUNT_SID=AC...              ← Dari twilio.com (boleh skip dulu)
TWILIO_AUTH_TOKEN=...                 ← Dari twilio.com (boleh skip dulu)
```

### Langkah 4 — Hidupkan server
```
Double-click: 2_START_SERVER.bat
```
- Server berjalan di: **http://localhost:8000**
- Biarkan tetingkap ini terbuka!

### Langkah 5 — Hidupkan Dashboard Web
```
Double-click: 3_START_DASHBOARD.bat  (tetingkap baru)
```
- Dashboard dibuka di: **http://localhost:3000**

### Langkah 6 — Daftar akaun admin
```
Double-click: 4_REGISTER_ADMIN.bat
```
- Isi nama, email, no. WhatsApp dan kata laluan
- Akaun pertama = akaun Owner (admin penuh)

### Langkah 7 — Auto-start (opsional)
```
Double-click: 6_AUTOSTART_ON_BOOT.bat  (klik kanan → Run as administrator)
```
- Server akan auto-start setiap kali Windows dihidupkan

---

## DAPATKAN IP UNTUK RASPBERRY PI

Selepas server berjalan, buka Command Prompt dan taip:
```cmd
ipconfig
```
Cari **"IPv4 Address"** — contoh: `192.168.1.105`

Kemudian masukkan dalam Pi config:
```
BACKEND_URL=http://192.168.1.105:8000
```

---

## CARA GUNA DASHBOARD

| Halaman | Fungsi |
|---|---|
| **Dashboard** | Pantau kejadian masa nyata, statistik |
| **Senarai Putih** | Tambah/padam nombor plat dibenarkan |
| **Profil Muka** | Daftar muka tuan rumah |
| **Analisis** | Muat naik foto untuk dianalisis AI |

---

## PENYELESAIAN MASALAH

| Masalah | Penyelesaian |
|---|---|
| `'python' is not recognized` | Pasang Python semula, tanda "Add to PATH" |
| `pip install gagal` | Jalankan sebagai Administrator |
| `Port 8000 already in use` | `netstat -ano \| findstr :8000` kemudian `taskkill /PID [nombor] /F` |
| Pi tidak boleh sambung | Jalankan `5_OPEN_FIREWALL.bat` |
| Dashboard tidak buka | Pasang Node.js dari nodejs.org |
| `face-recognition` gagal pasang | Pasang Visual Studio Build Tools dahulu |

---

## NOTA PENTING

- Komputer dan Raspberry Pi **mesti dalam WiFi yang sama**
- Jangan tutup tetingkap `2_START_SERVER.bat` semasa sistem berjalan
- Untuk akses dari luar rumah, perlukan **port forwarding** di router

---

*I Defender v1.0 — Sistem Pengawasan Kenderaan Pintar*
