# status_db.ps1 - Verifica o status do servidor PostgreSQL local
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\detect_pg.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Status do PostgreSQL Local" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$binDir = Find-PostgresBinDir
if (-not $binDir) {
    Write-Warning "Binarios do PostgreSQL nao encontrados no ambiente."
    exit 1
}

$DataDir = "$ScriptDir\data"

if (-not (Test-Path "$DataDir\PG_VERSION")) {
    Write-Warning "Cluster em $DataDir ainda nao foi inicializado."
    exit 0
}

Write-Host "[*] Verificando processo do servidor via pg_ctl..."
$output = & "$binDir\pg_ctl.exe" -D $DataDir status 2>&1
$output | Out-String | Write-Host

if ($LASTEXITCODE -eq 0) {
    Write-Host "[*] Testando conexao SQL..." -ForegroundColor Yellow
    $ver = & "$binDir\psql.exe" -h 127.0.0.1 -U postgres -t -c "SELECT version();" 2>$null
    if ($ver) {
        Write-Host "[OK] Conexao bem-sucedida! Versao ativa:" -ForegroundColor Green
        Write-Host "     $($ver.Trim())"
    } else {
        Write-Warning "Servidor respondeu, mas falhou ao executar consulta de teste."
    }
} else {
    Write-Host "[INFO] Servidor PostgreSQL local esta DESLIGADO." -ForegroundColor Red
}
