@echo off
chcp 65001 >nul
title I Defender — Buka Firewall
color 0C

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║     I DEFENDER — BUKA PORT FIREWALL          ║
echo  ║  (Supaya Raspberry Pi boleh sambung)          ║
echo  ╚══════════════════════════════════════════════╝
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo  [!] Perlu Admin rights! Klik kanan → Run as administrator
    pause
    exit /b 1
)

echo  Membuka port 8000 (Backend API)...
netsh advfirewall firewall add rule name="I Defender API Port 8000" dir=in action=allow protocol=TCP localport=8000 >nul
echo  [OK] Port 8000 dibuka

echo  Membuka port 3000 (Web Dashboard)...
netsh advfirewall firewall add rule name="I Defender Dashboard Port 3000" dir=in action=allow protocol=TCP localport=3000 >nul
echo  [OK] Port 3000 dibuka

echo.
echo  IP komputer anda (guna untuk Pi config):
ipconfig | findstr /i "IPv4"
echo.
echo  ════════════════════════════════════════════════
echo   Port dibuka! Raspberry Pi boleh sambung ke:
echo   http://[IP DI ATAS]:8000
echo  ════════════════════════════════════════════════
echo.
pause
