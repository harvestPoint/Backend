# install_pg.ps1 - Instala os binários do PostgreSQL via MSYS2 (sem privilégios de admin)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$ScriptDir\detect_pg.ps1"

Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host " HarvestPoint - Instalador Portatil do PostgreSQL" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$existingBin = Find-PostgresBinDir
if ($existingBin) {
    Write-Host "[OK] Binarios do PostgreSQL ja estao disponiveis em:" -ForegroundColor Green
    Write-Host "     $existingBin"
    exit 0
}

$pacman = Find-MsysPacman
if (-not $pacman) {
    Write-Error "Pacman do MSYS2 nao encontrado. Verifique se o Ruby com MSYS2 (RubyInstaller DevKit) esta instalado."
    exit 1
}

Write-Host "[*] Baixando e instalando PostgreSQL via MSYS2..." -ForegroundColor Yellow
Write-Host "    Executando: $pacman -S --noconfirm mingw-w64-ucrt-x86_64-postgresql"
& $pacman -S --noconfirm mingw-w64-ucrt-x86_64-postgresql

$newBin = Find-PostgresBinDir
if ($newBin) {
    Write-Host "[SUCESSO] PostgreSQL instalado com sucesso em:" -ForegroundColor Green
    Write-Host "          $newBin"
} else {
    Write-Error "Falha ao verificar os binarios apos a instalacao."
    exit 1
}
