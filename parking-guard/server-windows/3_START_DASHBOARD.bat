@echo off
chcp 65001 >nul
title I Defender — Web Dashboard
color 0E

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║       I DEFENDER WEB DASHBOARD               ║
echo  ╚══════════════════════════════════════════════╝
echo.

:: Semak Node.js
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo  [!] Node.js tidak dipasang!
    echo.
    echo  Muat turun dari: https://nodejs.org/
    echo  Pilih versi LTS
    echo.
    start https://nodejs.org/
    pause
    exit /b 1
)
echo  [OK] Node.js:
node --version
echo.

cd /d "%~dp0..\frontend"

:: Pasang npm packages (kali pertama)
if not exist node_modules\ (
    echo  [*] Pasang pakej npm (kali pertama ~2 minit)...
    npm install
    echo  [OK] npm packages dipasang
)

echo.
echo  ════════════════════════════════════════════════
echo   Dashboard dimulakan di: http://localhost:3000
echo   Log masuk dengan akaun yang anda daftar
echo  ════════════════════════════════════════════════
echo.

:: Set API URL ke localhost
set REACT_APP_API_URL=http://localhost:8000
set REACT_APP_WS_URL=ws://localhost:8000/api/stream/ws

npm start
pause
