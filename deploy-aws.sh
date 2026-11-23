#!/bin/bash
# ==============================================================================
# HarvestPoint - Script de Deploy Automatizado para AWS (EC2 / Ubuntu / Debian)
# ==============================================================================
set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # Sem Cor

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}   🌾 HarvestPoint - Deploy da API Rails em Servidor AWS        ${NC}"
echo -e "${CYAN}================================================================${NC}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# 1. Verificar arquivo .env
if [ ! -f ".env" ]; then
    echo -e "${RED}[ERRO] Arquivo .env não encontrado em $SCRIPT_DIR!${NC}"
    if [ -f ".env.example" ]; then
        echo -e "${YELLOW}[*] Criando .env a partir de .env.example...${NC}"
        cp .env.example .env
        echo -e "${YELLOW}[*] Edite o arquivo .env com suas senhas e SECRET_KEY_BASE antes de continuar!${NC}"
        echo -e "    Comando: nano .env"
        exit 1
    else
        echo -e "${RED}[ERRO] Nem .env nem .env.example existem. Abortando.${NC}"
        exit 1
    fi
fi

# 2. Verificar dependências (Docker e Docker Compose)
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}[*] Docker não encontrado. Deseja instalar o Docker automaticamente? (s/n)${NC}"
    read -r resp
    if [[ "$resp" =~ ^[sSyY]$ ]]; then
        echo -e "${YELLOW}[*] Instalando Docker via script oficial...${NC}"
        curl -fsSL https://get.docker.com | sh
        sudo usermod -aG docker "$USER"
        echo -e "${GREEN}[OK] Docker instalado com sucesso. Pode ser necessário reiniciar sua sessão SSH.${NC}"
    else
        echo -e "${RED}[ERRO] Docker é obrigatório para o deploy. Instale o docker e execute novamente.${NC}"
        exit 1
    fi
fi

# 3. Gerar SECRET_KEY_BASE se ainda estiver com valor padrão
if grep -q "c0ffeec0ffeec0ffeec0ffee" .env || grep -q "defina_uma_chave" .env; then
    echo -e "${YELLOW}[*] Gerando uma nova SECRET_KEY_BASE aleatória e segura...${NC}"
    NEW_KEY=$(openssl rand -hex 64)
    sed -i "s/SECRET_KEY_BASE=.*/SECRET_KEY_BASE=${NEW_KEY}/" .env
    echo -e "${GREEN}[OK] SECRET_KEY_BASE gerada e atualizada no .env.${NC}"
fi

# 4. Build das imagens Docker
echo -e "\n${YELLOW}[1/4] Construindo imagens Docker de produção...${NC}"
docker compose -f docker-compose.prod.yml build

# 5. Inicialização dos containers
echo -e "\n${YELLOW}[2/4] Subindo os containers em segundo plano...${NC}"
docker compose -f docker-compose.prod.yml up -d

# 6. Aguardar inicialização e estabilização
echo -e "\n${YELLOW}[3/4] Aguardando a API Rails e o banco de dados iniciarem...${NC}"
for i in {1..30}; do
    if docker compose -f docker-compose.prod.yml ps | grep -q "healthy"; then
        echo -e "${GREEN}[OK] Aplicação saudável e respondendo!${NC}"
        break
    fi
    echo -n "."
    sleep 2
done

# Se a flag --seed for passada, executa o db:seed
if [[ "$*" == *"--seed"* ]]; then
    echo -e "\n${YELLOW}[*] Executando sementes do banco de dados (rails db:seed)...${NC}"
    docker compose -f docker-compose.prod.yml exec app ./bin/rails db:seed
    echo -e "${GREEN}[OK] Banco de dados semeado com sucesso!${NC}"
fi

# 7. Verificação de Saúde
echo -e "\n${YELLOW}[4/4] Verificando endpoints de saúde...${NC}"
sleep 2

STATUS_UP=$(curl -s -o /dev/null -w "%{http_code}" http://localhost/up || echo "000")
if [ "$STATUS_UP" == "200" ]; then
    echo -e "${GREEN}[OK] Health Check /up: 200 OK${NC}"
else
    echo -e "${YELLOW}[AVISO] Health Check /up retornou status: ${STATUS_UP}${NC}"
fi

STATUS_HEALTH=$(curl -s http://localhost/api/health || echo "{}")
echo -e "Resposta da API (/api/health): ${CYAN}${STATUS_HEALTH}${NC}"

echo -e "\n${GREEN}================================================================${NC}"
echo -e "${GREEN}   🌾 DEPLOY CONCLUÍDO COM SUCESSO!                             ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo -e "A API está disponível na porta 80 do seu servidor AWS."
echo -e "Para visualizar os logs em tempo real:"
echo -e "   ${CYAN}docker compose -f docker-compose.prod.yml logs -f app${NC}"
echo -e "Para reiniciar o serviço:"
echo -e "   ${CYAN}docker compose -f docker-compose.prod.yml restart app${NC}"
echo -e "Para parar:"
echo -e "   ${CYAN}docker compose -f docker-compose.prod.yml down${NC}\n"
