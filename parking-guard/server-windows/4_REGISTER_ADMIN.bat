@echo off
chcp 65001 >nul
title I Defender — Daftar Akaun Admin
color 0D

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║     I DEFENDER — DAFTAR AKAUN ADMIN          ║
echo  ╚══════════════════════════════════════════════╝
echo.
echo  Pastikan server (2_START_SERVER.bat) sedang berjalan!
echo.

set /p USERNAME=Nama pengguna (contoh: admin):
set /p EMAIL=Email anda:
set /p WHATSAPP=No. WhatsApp (contoh: +60123456789):
set /p PASSWORD=Kata laluan:

echo.
echo  Mendaftar akaun...

curl -s -X POST http://localhost:8000/api/auth/register ^
  -H "Content-Type: application/json" ^
  -d "{\"username\":\"%USERNAME%\",\"email\":\"%EMAIL%\",\"password\":\"%PASSWORD%\",\"whatsapp_number\":\"%WHATSAPP%\"}"

echo.
echo.
echo  ════════════════════════════════════════════════
echo   Akaun berjaya didaftar!
echo   Log masuk di: http://localhost:3000
echo  ════════════════════════════════════════════════
echo.
pause
