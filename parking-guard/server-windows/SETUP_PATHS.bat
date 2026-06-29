@echo off
chcp 65001 >nul
:: Skrip ini dijalankan dari dalam folder server-windows
:: Ia akan salin fail requirements dan .env ke folder betul

set SCRIPT_DIR=%~dp0
set ROOT_DIR=%SCRIPT_DIR%..

:: Salin requirements ke root untuk digunakan oleh 1_INSTALL.bat
copy /Y "%SCRIPT_DIR%requirements-windows.txt" "%ROOT_DIR%\requirements-windows.txt" >nul 2>&1

:: Salin .env ke backend
if not exist "%ROOT_DIR%\backend\.env" (
    if exist "%SCRIPT_DIR%.env" (
        copy /Y "%SCRIPT_DIR%.env" "%ROOT_DIR%\backend\.env" >nul
    ) else (
        copy /Y "%SCRIPT_DIR%.env.example" "%ROOT_DIR%\backend\.env" >nul
    )
)

echo Done.
