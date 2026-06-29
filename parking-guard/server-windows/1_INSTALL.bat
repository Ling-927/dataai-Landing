@echo off
chcp 65001 >nul
title I Defender — Pemasangan Server
color 0A

echo.
echo  ╔══════════════════════════════════════════════╗
echo  ║         I DEFENDER SERVER SETUP              ║
echo  ║     Sistem Pengawasan Kenderaan Pintar        ║
echo  ╚══════════════════════════════════════════════╝
echo.

:: Pergi ke folder root projek (satu level atas dari server-windows)
cd /d "%~dp0.."

:: Semak admin rights
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo  [!] Sila klik kanan dan pilih "Run as administrator"
    pause
    exit /b 1
)

:: ── Langkah 1: Semak Python ──────────────────────────────────
echo  [1/6] Semak Python...
python --version >nul 2>&1
if %errorLevel% neq 0 (
    echo  [!] Python tidak dijumpai. Cuba py launcher...
    py --version >nul 2>&1
    if %errorLevel% neq 0 (
        echo  [!] Python tidak dipasang!
        echo.
        echo  Sila muat turun Python 3.11 dari:
        echo  https://www.python.org/downloads/
        echo.
        echo  PENTING: Tanda pada "Add Python to PATH" semasa pasang!
        echo.
        start https://www.python.org/downloads/release/python-3119/
        pause
        exit /b 1
    )
    set PYTHON=py
) else (
    set PYTHON=python
)
echo  [OK] Python jumpa:
%PYTHON% --version
echo.

:: ── Langkah 2: Buat virtual environment ─────────────────────
echo  [2/6] Buat persekitaran Python...
if exist venv\ (
    echo  [OK] venv sudah ada, guna semula
) else (
    %PYTHON% -m venv venv
    echo  [OK] venv dibuat
)
echo.

:: ── Langkah 3: Aktifkan venv ─────────────────────────────────
call venv\Scripts\activate.bat
echo  [3/6] Kemas kini pip...
python -m pip install --upgrade pip --quiet
echo  [OK] pip dikemas kini
echo.

:: ── Langkah 4: Pasang pakej ──────────────────────────────────
echo  [4/6] Pasang pakej Python (5-15 minit pertama kali)...
echo  Sila tunggu...
echo.
pip install -r server-windows\requirements-windows.txt
if %errorLevel% neq 0 (
    echo.
    echo  [!] Pemasangan gagal. Cuba jalankan semula sebagai Admin.
    pause
    exit /b 1
)
echo.
echo  [OK] Semua pakej dipasang
echo.

:: ── Langkah 5: Buat fail .env ────────────────────────────────
echo  [5/6] Sedia konfigurasi...
if not exist backend\.env (
    copy server-windows\.env.example backend\.env >nul
    echo  [OK] Fail backend\.env dibuat dari contoh
) else (
    echo  [OK] backend\.env sudah ada
)
echo.

:: ── Langkah 6: Dapatkan IP komputer ─────────────────────────
echo  [6/6] IP Address komputer anda:
echo.
ipconfig | findstr /i "IPv4"
echo.
echo  ════════════════════════════════════════════════
echo   Catat IP di atas untuk diisi dalam Pi config!
echo   Contoh: BACKEND_URL=http://192.168.1.XXX:8000
echo  ════════════════════════════════════════════════
echo.
echo  Pemasangan BERJAYA!
echo.
echo  Seterusnya:
echo   1. Edit fail backend\.env (buka dengan Notepad)
echo   2. Jalankan server-windows\2_START_SERVER.bat
echo.
pause
