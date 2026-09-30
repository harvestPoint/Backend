# init_db.ps1 - Inicializa o cluster local do PostgreSQL em testedb\data
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\detect_pg.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Inicializador de Cluster Local (initdb)" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$binDir = Find-PostgresBinDir
if (-not $binDir) {
    Write-Warning "Binarios do PostgreSQL nao encontrados. Tentando instalar..."
    & "$ScriptDir\install_pg.ps1"
    $binDir = Find-PostgresBinDir
    if (-not $binDir) {
        Write-Error "Nao foi possivel localizar os binarios do PostgreSQL."
        exit 1
    }
}

$DataDir = "$ScriptDir\data"

if (Test-Path "$DataDir\PG_VERSION") {
    Write-Host "[OK] O cluster de banco de dados ja esta inicializado em:" -ForegroundColor Green
    Write-Host "     $DataDir"
    exit 0
}

Write-Host "[*] Criando e inicializando cluster em: $DataDir" -ForegroundColor Yellow
New-Item -ItemType Directory -Force -Path $DataDir | Out-Null

& "$binDir\initdb.exe" -D $DataDir -U postgres -A trust -E UTF8

if (Test-Path "$DataDir\PG_VERSION") {
    Write-Host "[SUCESSO] Cluster inicializado com sucesso em $DataDir" -ForegroundColor Green
} else {
    Write-Error "Falha ao inicializar o cluster de banco de dados."
    exit 1
}
