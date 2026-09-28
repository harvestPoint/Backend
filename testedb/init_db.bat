@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0init_db.ps1"
if %errorlevel% neq 0 (
    echo.
    echo Ocorreu um erro durante a inicializacao do cluster.
    pause
)
