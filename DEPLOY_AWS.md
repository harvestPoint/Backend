# 🚀 Guia Completo de Deploy do Backend HarvestPoint na AWS

Este guia orienta o deploy em produção da API **HarvestPoint (Ruby on Rails 8.1 + PostgreSQL)** na infraestrutura da **Amazon Web Services (AWS)**.

---

## 🏗️ 1. Arquiteturas Recomendadas

| Opção | Perfil | Custo Estimado | Complexidade |
|---|---|---|---|
| **Opção A: AWS EC2 + Docker Compose (Recomendada)** | Tudo em uma única VM (Rails 8 + Thruster + Postgres em containers) | Baixo (~$10-15/mês no t3.small ou Free Tier) | ⭐ Baixa (Automatizada via `deploy-aws.sh`) |
| **Opção B: AWS EC2 + AWS RDS PostgreSQL** | Rails na EC2 e banco em serviço gerenciado RDS PostgreSQL | Médio (~$30-45/mês) | ⭐⭐ Média (Recomendada para alta tolerância a falhas) |
| **Opção C: AWS ECS Fargate / App Runner** | Containers serverless sem gerenciar servidores Linux | Variável conforme uso | ⭐⭐⭐ Alta |

---

## 🛡️ 2. Pré-requisitos na AWS

1. **Conta na AWS** com permissões para criar instâncias EC2 e grupos de segurança.
2. **Par de Chaves SSH (`.pem`)** criado no console da AWS (ex: `harvestpoint-key.pem`).
3. **Security Group (Grupo de Segurança)** com as seguintes regras de entrada (Inbound Rules):
   - **SSH (Porta 22):** Origem `Meu IP` (ou `0.0.0.0/0` se IP dinâmico)
   - **HTTP (Porta 80):** Origem `0.0.0.0/0` (Para acesso público à API e validação Certbot)
   - **HTTPS (Porta 443):** Origem `0.0.0.0/0` (Para tráfego seguro)

---

## 💻 3. Passo a Passo de Deploy (Opção A: EC2 com Docker Compose)

### Passo 1: Criar a Instância EC2
1. No console da AWS, acesse **EC2 > Launch Instances**.
2. **Nome:** `harvestpoint-backend-prod`.
3. **AMI (Sistema Operacional):** `Ubuntu Server 24.04 LTS (HVM), SSD Volume Type` (64-bit x86 ou ARM).
4. **Tipo de Instância:** `t3.small` (2 vCPU, 2GB RAM) ou `t4g.small` (ARM). *O t2.micro do Free Tier funciona, mas 2GB de RAM é ideal para compilação de gems e bootsnap.*
5. **Key Pair:** Selecione sua chave `.pem`.
6. **Network Settings:** Selecione o Security Group com as portas **22, 80 e 443** abertas.
7. **Storage:** 20 GB a 30 GB gp3.
8. Clique em **Launch Instance**.

---

### Passo 2: Conectar à Instância via SSH
No seu terminal local (PowerShell, Git Bash ou Linux):

```bash
# Ajuste as permissões da chave se estiver no Linux/Mac
chmod 400 harvestpoint-key.pem

# Conecte usando o IP público da sua instância EC2
ssh -i "harvestpoint-key.pem" ubuntu@SEU_IP_PUBLICO_AWS
```

---

### Passo 3: Clonar o Repositório e Preparar o Ambiente

Dentro da instância EC2:

```bash
# Atualizar pacotes do sistema
sudo apt update && sudo apt upgrade -y

# Instalar Git e Docker (se ainda não tiver)
sudo apt install -y git curl
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Aplicar grupo docker imediatamente sem deslogar
newgrp docker

# Clonar o repositório do Backend
git clone https://github.com/harvestPoint/Backend.git
cd Backend
```

---

### Passo 4: Configurar as Variáveis de Ambiente (`.env`)

Copie o arquivo de exemplo:

```bash
cp .env.example .env
nano .env
```

Edite os seguintes campos essenciais:

```env
RAILS_ENV=production

# Gere uma chave com: openssl rand -hex 64
SECRET_KEY_BASE=sua_chave_gerada_aqui

# Senha segura para o PostgreSQL
DB_PASSWORD=CrieUmaSenhaForteParaOSeuBanco2026!

# URL do seu frontend (para permitir requisições Ajax/Fetch)
FRONTEND_ORIGINS=http://SEU_DOMINIO_OU_IP_FRONTEND,https://meuapp.com
```

Pressione `Ctrl+O` para salvar e `Ctrl+X` para sair do nano.

---

### Passo 5: Executar o Deploy Automatizado

Execute o script de deploy:

```bash
# Dar permissão de execução (se necessário)
chmod +x deploy-aws.sh

# Executar o deploy (adicione --seed na primeira vez para carregar dados iniciais)
./deploy-aws.sh --seed
```

O script irá:
1. Validar seu `.env`.
2. Fazer o build otimizado da imagem Rails 8 com jemalloc e Thruster.
3. Subir o container da API e do PostgreSQL.
4. Aguardar o banco estar pronto e rodar `rails db:prepare` automaticamente.
5. Inserir os registros de demonstração (culturas, lotes, usuários) via `db:seed`.
6. Testar os endpoints de saúde (`/up` e `/api/health`).

---

### Passo 6: Testar a API

No seu navegador ou via curl:

```bash
curl http://SEU_IP_PUBLICO_AWS/api/health
```

Você deverá receber:
```json
{
  "status": "healthy",
  "service": "harvestpoint-api",
  "environment": "production",
  "database": "connected",
  "timestamp": "2026-11-23T..."
}
```

E o health check oficial do Rails:
```bash
curl http://SEU_IP_PUBLICO_AWS/up
# Retorno: 200 OK
```

---

## 🗄️ 4. Usando AWS RDS PostgreSQL (Banco Gerenciado)

Se preferir usar o AWS RDS em vez do PostgreSQL local em container:

1. No console da AWS, crie uma instância **RDS PostgreSQL** (versão 16 ou 17).
2. Garanta que o Security Group do RDS permita conexões na porta 5432 vindas do Security Group da sua EC2.
3. No arquivo `.env` da EC2, basta preencher a variável `DATABASE_URL`:
   ```env
   DATABASE_URL=postgresql://seu_usuario:sua_senha@harvestpoint-db.xxxxxx.us-east-1.rds.amazonaws.com:5432/harvestpoint_production
   ```
4. No arquivo `docker-compose.prod.yml`, você pode comentar o bloco do serviço `db` ou iniciar apenas a aplicação:
   ```bash
   docker compose -f docker-compose.prod.yml up -d app
   ```

---

## 🔒 5. Configurar HTTPS / SSL com Certbot (Let's Encrypt)

Para associar um domínio (ex: `api.harvestpoint.com.br`) e obter SSL gratuito:

1. Aponte o DNS do seu domínio (no Route 53 ou seu registrador) para o **IP público da EC2** (tipo A Record).
2. Na EC2, instale o Nginx e Certbot:
   ```bash
   sudo apt install -y nginx certbot python3-certbot-nginx
   ```
3. No arquivo `.env`, altere a porta da aplicação para não conflitar com a porta 80 do Nginx:
   ```env
   APP_PORT=3333
   ```
   E reinicie a API:
   ```bash
   docker compose -f docker-compose.prod.yml up -d
   ```
4. Copie o arquivo `nginx.conf`:
   ```bash
   sudo cp nginx.conf /etc/nginx/sites-available/harvestpoint
   sudo ln -s /etc/nginx/sites-available/harvestpoint /etc/nginx/sites-enabled/
   sudo rm -f /etc/nginx/sites-enabled/default
   sudo nginx -t && sudo systemctl reload nginx
   ```
5. Emita o certificado SSL:
   ```bash
   sudo certbot --nginx -d api.seudominio.com.br
   ```

---

## 🔄 6. Configurar Inicialização Automática no Boot da EC2 (Systemd)

Para que a API suba automaticamente se a máquina for reiniciada pela AWS:

```bash
# Copie o arquivo de serviço do systemd
sudo cp harvestpoint.service /etc/systemd/system/

# Ative e inicie o serviço
sudo systemctl daemon-reload
sudo systemctl enable harvestpoint.service
```

---

## 🌐 7. Conectando o Frontend ao Backend AWS

No seu projeto **Frontend (`Frontend/apps/web`)**:

1. Crie o arquivo `.env.production`:
   ```env
   VITE_API_URL=http://SEU_IP_PUBLICO_AWS
   # Ou com domínio e SSL:
   # VITE_API_URL=https://api.seudominio.com.br
   ```
2. Gere o build de produção:
   ```bash
   npm run build
   ```
3. O build gerado na pasta `dist/` fará todas as requisições para a sua API na AWS com Bearer Token e cabeçalhos CORS configurados!

---

## 🛠️ 8. Comandos Úteis de Manutenção na AWS

| Ação | Comando |
|---|---|
| **Ver logs da API em tempo real** | `docker compose -f docker-compose.prod.yml logs -f app` |
| **Ver logs do banco de dados** | `docker compose -f docker-compose.prod.yml logs -f db` |
| **Reiniciar a API** | `docker compose -f docker-compose.prod.yml restart app` |
| **Executar console do Rails** | `docker compose -f docker-compose.prod.yml exec app ./bin/rails console` |
| **Rodar migrações pendentes** | `docker compose -f docker-compose.prod.yml exec app ./bin/rails db:migrate` |
| **Fazer backup do banco local** | `docker exec -t harvestpoint_db pg_dump -U harvestpoint harvestpoint_production > backup_$(date +%F).sql` |
| **Atualizar código após novo commit** | `git pull && ./deploy-aws.sh` |
