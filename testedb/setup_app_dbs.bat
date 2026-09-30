@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup_app_dbs.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Ocorreu um erro durante a preparacao dos bancos.
    pause
)
