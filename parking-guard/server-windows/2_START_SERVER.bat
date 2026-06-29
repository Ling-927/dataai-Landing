@echo off
chcp 65001 >nul
title I Defender — Server Berjalan
color 0B

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║       I DEFENDER SERVER SEDANG BERJALAN      ║
echo  ╚══════════════════════════════════════════════╝
echo.

:: Pergi ke folder root projek
cd /d "%~dp0.."

:: Semak venv
if not exist venv\Scripts\activate.bat (
    echo  [!] Sila jalankan 1_INSTALL.bat dahulu!
    pause
    exit /b 1
)

call venv\Scripts\activate.bat

:: IP semasa
echo  IP komputer anda:
ipconfig | findstr /i "IPv4"
echo.

:: Buat folder
if not exist uploads mkdir uploads
if not exist ai-models mkdir ai-models
if not exist logs mkdir logs

:: Download model AI kalau belum ada
if not exist ai-models\yolov8n.pt (
    echo  [*] Muat turun model YOLOv8n (kali pertama sahaja ~6MB)...
    python -c "from ultralytics import YOLO; YOLO('yolov8n.pt')" 2>nul
    if exist yolov8n.pt (
        move yolov8n.pt ai-models\ >nul
        echo  [OK] Model YOLOv8n dimuat turun
    )
)

echo.
echo  ════════════════════════════════════════════════
echo   Server I Defender sedang dimulakan...
echo   Buka browser: http://localhost:8000
echo   Dashboard  : http://localhost:3000 (jika frontend running)
echo   API Docs   : http://localhost:8000/docs
echo  ════════════════════════════════════════════════
echo.
echo  Tekan Ctrl+C untuk hentikan server
echo.

:: Mulakan server
cd backend
python -m uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload --log-level info

pause
