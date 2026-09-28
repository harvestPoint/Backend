@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start_db.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Ocorreu um erro ao iniciar o PostgreSQL.
    pause
)
