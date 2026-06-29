@echo off
chcp 65001 >nul
title I Defender — Auto Start
color 0A

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║   I DEFENDER — AUTO START SEMASA BOOT        ║
echo  ╚══════════════════════════════════════════════╝
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo  [!] Perlu Admin rights!
    pause
    exit /b 1
)

:: Dapatkan path folder semasa
set CURRENT_DIR=%~dp0
set CURRENT_DIR=%CURRENT_DIR:~0,-1%

:: Buat Task Scheduler entry
schtasks /create /tn "IDefenderServer" /tr "\"%CURRENT_DIR%\2_START_SERVER.bat\"" /sc onlogon /ru "%USERNAME%" /f >nul

if %errorLevel% equ 0 (
    echo  [OK] I Defender Server akan auto-start setiap kali log masuk Windows
    echo.
    echo  Untuk buang auto-start:
    echo  schtasks /delete /tn "IDefenderServer" /f
) else (
    echo  [!] Gagal buat task. Cuba jalankan sebagai Admin.
)
echo.
pause
