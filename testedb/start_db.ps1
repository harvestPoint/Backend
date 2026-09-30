# start_db.ps1 - Inicia o servidor PostgreSQL local
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\detect_pg.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Iniciar PostgreSQL Local" -ForegroundColor Cyan
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
$LogFile = "$ScriptDir\postgres.log"

if (-not (Test-Path "$DataDir\PG_VERSION")) {
    Write-Host "[*] Cluster nao encontrado. Inicializando..." -ForegroundColor Yellow
    & "$ScriptDir\init_db.ps1"
}

# Verificar se o servidor ja esta rodando
$statusOutput = & "$binDir\pg_ctl.exe" -D $DataDir status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[OK] PostgreSQL ja esta rodando!" -ForegroundColor Green
    exit 0
}

Write-Host "[*] Iniciando PostgreSQL na porta 5432..." -ForegroundColor Yellow
Write-Host "    Log do servidor: $LogFile"
& "$binDir\pg_ctl.exe" -D $DataDir -l $LogFile start

Start-Sleep -Seconds 2

# Verificar status apos inicio
$statusOutput = & "$binDir\pg_ctl.exe" -D $DataDir status 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "[SUCESSO] PostgreSQL iniciado com sucesso!" -ForegroundColor Green

    # Garante que o usuario do Windows exista como superusuario para que o Rails conecte sem senhas
    $currentUser = $env:USERNAME
    if ($currentUser -and $currentUser -ne "postgres") {
        & "$binDir\createuser.exe" -h 127.0.0.1 -U postgres -s $currentUser 2>$null
    }
} else {
    Write-Error "Falha ao iniciar o PostgreSQL. Verifique o log em: $LogFile"
    exit 1
}
