# 🐘 testedb — PostgreSQL Local e Portátil para o HarvestPoint

Esta pasta contém um sistema autônomo, portátil e leve para executar o **PostgreSQL localmente no Windows**, projetado para cenários em que o desenvolvedor **não possui privilégios de administrador** ou **não tem o PostgreSQL instalado como serviço no sistema operacional**.

---

## 🎯 Por que esta solução existe?

Normalmente, instalar o PostgreSQL no Windows exige instaladores com privilégios de administrador, criação de serviços no Windows (`services.msc`), ou uso de Docker (que por sua vez requer WSL2/Hyper-V).

Como o ambiente de desenvolvimento Rails no Windows utiliza o **RubyInstaller**, ele já traz consigo o ambiente **MSYS2** (`C:\Ruby*-x64\msys64`). Aproveitando o gerenciador de pacotes `pacman` do MSYS2, conseguimos obter os binários nativos oficiais do PostgreSQL (`postgres.exe`, `pg_ctl.exe`, `initdb.exe`, `psql.exe`, etc.) que rodam inteiramente em **modo usuário (user space)**, sem alterar o registro do Windows e sem exigir permissões especiais.

---

## 📁 Estrutura de Arquivos

```text
Backend/
├── harvestpoint/               # Código-fonte da aplicação Ruby on Rails
└── testedb/                    # Ferramentas do PostgreSQL local portátil
    ├── detect_pg.ps1           # Helper para localizar os binários do PostgreSQL/MSYS2
    ├── install_pg.bat/.ps1     # Baixa/instala os binários via pacman se necessário
    ├── init_db.bat/.ps1        # Inicializa o cluster de dados em testedb\data
    ├── start_db.bat/.ps1       # Inicia o serviço PostgreSQL em segundo plano
    ├── stop_db.bat/.ps1        # Encerra o serviço PostgreSQL com segurança
    ├── status_db.bat/.ps1      # Verifica se o PostgreSQL está ativo e respondendo
    ├── setup_app_dbs.bat/.ps1  # Cria os bancos da app e roda as migrations do Rails
    ├── start_all.bat/.ps1      # Inicia o PostgreSQL e em seguida roda o Rails Server
    ├── data/                   # Diretório com as tabelas locais (ignorado no Git)
    ├── postgres.log            # Arquivo de log com a saída do PostgreSQL
    └── .gitignore              # Protege data/ e logs de irem para o repositório
```

> **Nota:** Todos os scripts possuem versão `.bat` (para duplo clique no Windows Explorer ou uso no Prompt CMD) e versão `.ps1` (para execução no PowerShell).

---

## 🚀 Guia Rápido de Uso

### 1. Inicialização inicial (Primeira vez na máquina)

Se os binários do PostgreSQL ainda não estiverem disponíveis, execute:
```cmd
install_pg.bat
```
*(Se os binários já estiverem instalados no MSYS2, o script detectará automaticamente e não fará download desnecessário).*

Em seguida, inicialize a estrutura de diretórios e tabelas locais:
```cmd
init_db.bat
```
*(Isso cria a pasta `testedb\data` com agrupamento UTF-8 e autenticação local liberada para desenvolvimento).*

---

### 2. Iniciar o Banco de Dados

Para subir o PostgreSQL na porta `5432`:
```cmd
start_db.bat
```
Você verá a mensagem:
```text
esperando o servidor iniciar....feito
servidor iniciado
[SUCESSO] PostgreSQL iniciado com sucesso!
```

---

### 3. Preparar os Bancos da Aplicação e Migrations

Com o PostgreSQL rodando, execute o script que cria os bancos `harvestpoint_development` e `harvestpoint_test` e roda as migrations do Rails:
```cmd
setup_app_dbs.bat
```

---

### 4. Iniciar o Backend Rails

Você pode iniciar o servidor Rails normalmente na pasta `Backend/harvestpoint`:
```powershell
cd Backend/harvestpoint
bundle exec rails s
```
Ou utilizar o atalho direto dentro de `testedb`:
```cmd
start_all.bat
```
O servidor estará respondendo na porta `3333` (alinhada ao proxy do frontend Vite).

---

### 5. Parar o Banco de Dados

Ao encerrar o trabalho:
```cmd
stop_db.bat
```

---

### 6. Verificar o Status

Para checar se o banco está ativo e testar uma consulta de conexão:
```cmd
status_db.bat
```

---

## 🛠️ Comandos Manuais (Referência para PowerShell)

Se preferir rodar os comandos diretamente no PowerShell sem os scripts auxiliares:

### Inicializar novo cluster
```powershell
C:\Ruby40-x64\msys64\ucrt64\bin\initdb.exe -D "C:\Users\aluno\Documents\vscodefabio\harvest\Backend\testedb\data" -U postgres -A trust -E UTF8
```

### Iniciar o PostgreSQL
```powershell
C:\Ruby40-x64\msys64\ucrt64\bin\pg_ctl.exe -D "C:\Users\aluno\Documents\vscodefabio\harvest\Backend\testedb\data" -l "C:\Users\aluno\Documents\vscodefabio\harvest\Backend\testedb\postgres.log" start
```

### Parar o PostgreSQL
```powershell
C:\Ruby40-x64\msys64\ucrt64\bin\pg_ctl.exe -D "C:\Users\aluno\Documents\vscodefabio\harvest\Backend\testedb\data" stop -m fast
```

### Status do PostgreSQL
```powershell
C:\Ruby40-x64\msys64\ucrt64\bin\pg_ctl.exe -D "C:\Users\aluno\Documents\vscodefabio\harvest\Backend\testedb\data" status
```

### Abrir o console SQL interativo (`psql`)
```powershell
C:\Ruby40-x64\msys64\ucrt64\bin\psql.exe -h 127.0.0.1 -U postgres
```

---

## ⚙️ Integração com o `database.yml` do Rails

O `Backend/harvestpoint/config/database.yml` já está perfeitamente alinhado a este ambiente:
```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  max_connections: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  host: <%= ENV.fetch("DB_HOST", "localhost") %>
```

* **Host:** `localhost` / `127.0.0.1`
* **Porta:** `5432` (padrão)
* **Usuário:** Conecta como `postgres` ou com o usuário do Windows atual (`aluno`), ambos já configurados como superusuários sem necessidade de senha em ambiente de desenvolvimento local.

---

## 🔍 Resolução de Dúvidas e Problemas

### 1. "Porta 5432 já está em uso"
Se outra instância do PostgreSQL ou MySQL estiver ocupando a porta 5432:
* Verifique quem está usando a porta: `netstat -ano | findstr 5432`
* Se for uma instância anterior do `postgres.exe`, encerre-a com `stop_db.bat` ou via Gerenciador de Tarefas.

### 2. Onde vejo erros do banco?
Abra o arquivo [Backend/testedb/postgres.log](file:///c:/Users/aluno/Documents/vscodefabio/harvest/Backend/testedb/postgres.log). Ele registra qualquer falha de inicialização, recuperação ou conexões rejeitadas.

### 3. Como resetar completamente o banco de testes?
1. Pare o banco: `stop_db.bat`
2. Apague a pasta `data`: `Remove-Item -Recurse -Force Backend\testedb\data`
3. Execute `init_db.bat` e depois `setup_app_dbs.bat`.
Um banco completamente limpo será recriado instantaneamente.
