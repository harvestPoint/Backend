@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0stop_db.ps1"
if %errorlevel% neq 0 (
    echo.
    pause
)
