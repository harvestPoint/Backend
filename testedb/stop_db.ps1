# stop_db.ps1 - Para o servidor PostgreSQL local
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\detect_pg.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Parar PostgreSQL Local" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$binDir = Find-PostgresBinDir
if (-not $binDir) {
    Write-Error "Nao foi possivel localizar os binarios do PostgreSQL."
    exit 1
}

$DataDir = "$ScriptDir\data"

if (-not (Test-Path "$DataDir\PG_VERSION")) {
    Write-Warning "Cluster em $DataDir nao encontrado."
    exit 0
}

Write-Host "[*] Parando servidor PostgreSQL..." -ForegroundColor Yellow
& "$binDir\pg_ctl.exe" -D $DataDir stop -m fast

if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCESSO] Servidor PostgreSQL parado." -ForegroundColor Green
} else {
    Write-Host "[INFO] O servidor ja estava parado ou nao pode ser encerrado."
}
