@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0status_db.ps1"
echo.
pause
