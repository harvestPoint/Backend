# setup_app_dbs.ps1 - Cria os bancos da aplicacao e executa as migrations
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$HarvestpointDir = Resolve-Path "$ScriptDir\..\harvestpoint"
. "$ScriptDir\detect_pg.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Preparacao dos Bancos de Dados da App" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

# 1. Garantir que o banco de dados esta rodando
& "$ScriptDir\start_db.ps1"

$binDir = Find-PostgresBinDir
if ($binDir) {
    Write-Host "[*] Criando bancos 'harvestpoint_development' e 'harvestpoint_test'..." -ForegroundColor Yellow
    & "$binDir\createdb.exe" -h 127.0.0.1 -U postgres harvestpoint_development 2>$null
    & "$binDir\createdb.exe" -h 127.0.0.1 -U postgres harvestpoint_test 2>$null
}

Write-Host "[*] Executando migrations do Rails..." -ForegroundColor Yellow
Push-Location $HarvestpointDir
try {
    bundle exec rails db:migrate
    bundle exec rails db:seed
    bundle exec rails db:test:prepare
    Write-Host "[SUCESSO] Bancos e tabelas configurados e prontos para uso!" -ForegroundColor Green
} finally {
    Pop-Location
}
