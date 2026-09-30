# start_all.ps1 - Inicia o PostgreSQL local e em seguida sobe o servidor Rails
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HarvestpointDir = Resolve-Path "$ScriptDir\..\harvestpoint"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Inicializacao Completa (DB + Backend)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Iniciar PostgreSQL
& "$ScriptDir\start_db.ps1"

# 2. Iniciar Rails Server
Write-Host "`n[*] Iniciando Rails Server em http://localhost:3333..." -ForegroundColor Yellow
Push-Location $HarvestpointDir
try {
    bundle exec rails s
} finally {
    Pop-Location
}
