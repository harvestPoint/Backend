@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install_pg.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Ocorreu um erro durante a instalacao.
    pause
)
