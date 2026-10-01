# detect_pg.ps1 - Localiza os binários do PostgreSQL no ambiente
param()

function Find-PostgresBinDir {
    # 1. Verificar se postgres já está no PATH
    $cmd = Get-Command "postgres.exe" -ErrorAction SilentlyContinue
    if ($cmd) {
        return (Split-Path $cmd.Source)
    }

    # 2. Verificar via instalação do Ruby atual (MSYS2 ucrt64 ou mingw64)
    $rubyCmd = Get-Command "ruby.exe" -ErrorAction SilentlyContinue
    if ($rubyCmd) {
        $rubyRoot = Split-Path (Split-Path $rubyCmd.Source)
        $candidates = @(
            "$rubyRoot\msys64\ucrt64\bin",
            "$rubyRoot\msys64\mingw64\bin",
            "$rubyRoot\msys64\clang64\bin"
        )
        foreach ($c in $candidates) {
            if (Test-Path "$c\postgres.exe") {
                return $c
            }
        }
    }

    # 3. Verificar caminhos padrão do RubyInstaller em C:\
    $rubyDirs = Get-ChildItem -Path "C:\" -Filter "Ruby*-x64" -Directory -ErrorAction SilentlyContinue
    foreach ($r in $rubyDirs) {
        $candidates = @(
            "$($r.FullName)\msys64\ucrt64\bin",
            "$($r.FullName)\msys64\mingw64\bin"
        )
        foreach ($c in $candidates) {
            if (Test-Path "$c\postgres.exe") {
                return $c
            }
        }
    }

    # 4. Verificar instalações padrão do instalador oficial do PostgreSQL
    $pgProgFiles = Get-ChildItem -Path "C:\Program Files\PostgreSQL" -Directory -ErrorAction SilentlyContinue
    foreach ($p in $pgProgFiles) {
        if (Test-Path "$($p.FullName)\bin\postgres.exe") {
            return "$($p.FullName)\bin"
        }
    }

    return $null
}

function Find-MsysPacman {
    $rubyCmd = Get-Command "ruby.exe" -ErrorAction SilentlyContinue
    if ($rubyCmd) {
        $rubyRoot = Split-Path (Split-Path $rubyCmd.Source)
        $pacman = "$rubyRoot\msys64\usr\bin\pacman.exe"
        if (Test-Path $pacman) {
            return $pacman
        }
    }

    $rubyDirs = Get-ChildItem -Path "C:\" -Filter "Ruby*-x64" -Directory -ErrorAction SilentlyContinue
    foreach ($r in $rubyDirs) {
        $pacman = "$($r.FullName)\msys64\usr\bin\pacman.exe"
        if (Test-Path $pacman) {
            return $pacman
        }
    }

    return $null
}
