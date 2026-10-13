# 🌾 HarvestPoint — Backend (API Rails)

![Ruby](https://img.shields.io/badge/Ruby-3.x-red?logo=ruby)
![Rails](https://img.shields.io/badge/Rails-8.1-CC0000?logo=rubyonrails)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-18-336791?logo=postgresql)
![Testes](https://img.shields.io/badge/testes-30%20%7C%20100%20assertions%20%7C%200%20falhas-brightgreen)
![Status](https://img.shields.io/badge/status-estável-success)

> API RESTful para o sistema de monitoramento agrícola do **Vale do São Francisco**. Recebe leituras de sensores ESP-32, gera alertas automáticos e recomendações de colheita via inteligência artificial heurística.

---

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Requisitos](#requisitos)
- [Configuração e Inicialização](#configuração-e-inicialização)
- [Variáveis de Ambiente](#variáveis-de-ambiente)
- [Estrutura do Banco de Dados](#estrutura-do-banco-de-dados)
- [Endpoints da API](#endpoints-da-api)
- [Autenticação](#autenticação)
- [Integração ESP-32](#integração-esp-32)
- [Arquitetura Interna](#arquitetura-interna)
- [Testes](#testes)

---

## Visão Geral

O HarvestPoint Backend é uma API **API-only** construída com Ruby on Rails 8.1. Ela gerencia:

- **Usuários e autenticação** via Bearer Token (BCrypt + token aleatório)
- **Propriedades, culturas e lotes** agrícolas
- **Sensores IoT** (ESP-32) com auto-registro e ingestão de leituras
- **Motor de alertas** automático: detecta temperatura ou umidade fora do intervalo ideal para a cultura do lote
- **Motor de IA de colheita**: calcula a janela ótima de colheita com base no ciclo médio da cultura, leituras acumuladas e dados climáticos
- **Preços de mercado** e **previsão climática** por propriedade

---

## Requisitos

| Componente     | Versão mínima |
|----------------|---------------|
| Ruby           | 3.2+          |
| Rails          | 8.1.3         |
| PostgreSQL     | 14+ (testado com 18) |
| Bundler        | 2.x           |

> O repositório inclui um PostgreSQL portátil em `Backend/testedb/` para desenvolvimento local no Windows, sem necessidade de instalação global.

---

## Configuração e Inicialização

### 1. Iniciar o PostgreSQL portátil

```powershell
cd Backend\testedb
.\start_db.ps1
```

Isso sobe uma instância PostgreSQL na **porta 5432** usando os dados em `testedb/data/`.

### 2. Instalar dependências Ruby

```powershell
cd Backend\harvestpoint
bundle install
```

### 3. Criar e migrar o banco de dados

```powershell
# No Windows (PowerShell)
rails db:create db:migrate db:seed
```

```bash
# No Linux/macOS
rails db:create db:migrate db:seed
```

O seed cria culturas padrão (uva, manga, tomate, melão, pimentão) com parâmetros de temperatura/umidade ideais, além de um usuário de demonstração.

### 4. Iniciar o servidor

```powershell
rails server -p 3333
```

A API ficará disponível em **`http://localhost:3333`**.

---

## Variáveis de Ambiente

| Variável         | Padrão          | Descrição                                             |
|------------------|-----------------|-------------------------------------------------------|
| `DB_PORT`        | `5432`          | Porta do PostgreSQL                                   |
| `DB_HOST`        | `127.0.0.1`     | Host do banco de dados                                |
| `DB_USERNAME`    | `postgres`      | Usuário do banco                                      |
| `DB_PASSWORD`    | _(vazio)_       | Senha do banco                                        |
| `RAILS_ENV`      | `development`   | Ambiente Rails                                        |
| `PORT`           | `3000`          | Porta do Puma (sobrescrita pelo `-p 3333`)            |

> Configure em um arquivo `.env` na raiz ou exporte no terminal antes de iniciar o servidor.

---

## Estrutura do Banco de Dados

O schema completo é criado pela migration `20261001160000_create_harvestpoint_complete_schema.rb`.

### Diagrama de Relacionamentos

```
usuarios
  └── propriedades (usuario_id)
        ├── lotes (propriedade_id)
        │     ├── historico_cultivos (lote_id)
        │     ├── sensores (lote_id)
        │     │     ├── leitura_sensores (sensor_id)
        │     │     └── alertas (sensor_id)
        │     └── recomendacao_colheitas (lote_id)
        └── clima_regioes (propriedade_id)
culturas
  ├── lotes (cultura_id)
  └── preco_mercados (cultura_id)
```

### Tabelas

| Tabela                  | Descrição                                                  |
|-------------------------|------------------------------------------------------------|
| `usuarios`              | Agricultores e técnicos. Campos: `nome`, `email`, `senha_digest`, `api_token`, `tipo_usuario`, `cpf_cnpj`, `telefone` |
| `propriedades`          | Fazendas/sítios. Campos: `nome`, `municipio`, `latitude`, `longitude`, `area_total` |
| `culturas`              | Tipos de cultura (uva, manga…). Inclui limites de `temperatura_min/max`, `umidade_min/max`, `ciclo_medio_dias` |
| `lotes`                 | Parcelas de terra. Vincula `propriedade` + `cultura`. Campos: `codigo`, `area_ha`, `data_plantio`, `status` |
| `historico_cultivos`    | Histórico de plantios por lote                              |
| `preco_mercados`        | Cotações de mercado por cultura (`preco_medio`, `moeda`, `data_cotacao`) |
| `clima_regioes`         | Previsão climática por propriedade (`temp_min/max`, `chance_chuva_percentual`, `precipitacao_mm`) |
| `sensores`              | Dispositivos IoT. Identificados por `codigo` (MAC address). Vinculados a um lote |
| `leitura_sensores`      | Séries temporais de `temperatura` e `umidade` por sensor   |
| `alertas`               | Alertas gerados automaticamente. Campos: `tipo`, `severidade`, `mensagem`, `resolvido` |
| `recomendacao_colheitas`| Janelas de colheita calculadas por IA. Campos: `data_inicio`, `data_fim`, `grau_confianca`, `status` |

---

## Endpoints da API

> **Base URL:** `http://localhost:3333/api`
>
> Todos os endpoints (exceto `POST /auth/signup`, `POST /auth/login` e `POST /sensores/leitura`) exigem autenticação via **Bearer Token**.

---

### 🔐 Autenticação

#### `POST /api/auth/signup` — Cadastro de usuário

```http
POST /api/auth/signup
Content-Type: application/json

{
  "nome": "João Silva",
  "email": "joao@fazenda.com",
  "senha": "senha123",
  "role": "proprietario",
  "propriedade": "Fazenda Boa Vista",
  "cpf_cnpj": "123.456.789-00",
  "telefone": "(87) 99999-0000"
}
```

**Resposta 201:**
```json
{
  "data": {
    "user": {
      "id": 1,
      "nome": "João Silva",
      "email": "joao@fazenda.com",
      "role": "proprietario",
      "propriedade": "Fazenda Boa Vista"
    },
    "token": "abc123xyz..."
  }
}
```

---

#### `POST /api/auth/login` — Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "email": "joao@fazenda.com",
  "senha": "senha123"
}
```

**Resposta 200:**
```json
{
  "data": {
    "user": { "id": 1, "nome": "João Silva", "email": "joao@fazenda.com", "role": "proprietario" },
    "token": "abc123xyz..."
  }
}
```

---

#### `DELETE /api/auth/logout` — Logout

```http
DELETE /api/auth/logout
Authorization: Bearer abc123xyz...
```

**Resposta 200:** `{ "message": "Logout realizado com sucesso" }`

---

#### `GET /api/auth/me` — Usuário atual

```http
GET /api/auth/me
Authorization: Bearer abc123xyz...
```

**Resposta 200:** `{ "data": { "user": { ... } } }`

---

### 🏠 Propriedades

| Método | Rota                       | Descrição                     |
|--------|----------------------------|-------------------------------|
| `GET`  | `/api/propriedades`        | Lista propriedades do usuário  |
| `POST` | `/api/propriedades`        | Cria nova propriedade          |
| `GET`  | `/api/propriedades/:id`    | Detalhe da propriedade         |
| `PATCH`| `/api/propriedades/:id`    | Atualiza propriedade           |
| `DELETE`| `/api/propriedades/:id`   | Remove propriedade             |

**Exemplo POST:**
```json
{
  "nome": "Fazenda Boa Vista",
  "municipio": "Juazeiro",
  "latitude": -9.41,
  "longitude": -40.50,
  "area_total": 120.5
}
```

---

### 🌿 Culturas

| Método  | Rota                  | Descrição            |
|---------|-----------------------|----------------------|
| `GET`   | `/api/culturas`       | Lista todas culturas  |
| `POST`  | `/api/culturas`       | Cadastra cultura      |
| `GET`   | `/api/culturas/:id`   | Detalhe da cultura    |
| `PATCH` | `/api/culturas/:id`   | Atualiza cultura      |
| `DELETE`| `/api/culturas/:id`   | Remove cultura        |

**Exemplo POST:**
```json
{
  "nome": "Uva",
  "ciclo_medio_dias": 120,
  "temperatura_min": 20.0,
  "temperatura_max": 35.0,
  "umidade_min": 60.0,
  "umidade_max": 85.0
}
```

---

### 🗺️ Lotes

| Método  | Rota               | Descrição            |
|---------|--------------------|----------------------|
| `GET`   | `/api/lotes`       | Lista lotes          |
| `POST`  | `/api/lotes`       | Cria lote            |
| `GET`   | `/api/lotes/:id`   | Detalhe do lote      |
| `PATCH` | `/api/lotes/:id`   | Atualiza lote        |
| `DELETE`| `/api/lotes/:id`   | Remove lote          |

**Exemplo POST:**
```json
{
  "codigo": "L-001",
  "propriedade_id": 1,
  "cultura_id": 2,
  "area_ha": 15.5,
  "data_plantio": "2026-05-10",
  "status": "ativo"
}
```

**Resposta GET /api/lotes/:id** (com dados enriquecidos):
```json
{
  "data": {
    "id": 1,
    "codigo": "L-001",
    "cultura": "Uva",
    "ultima_temperatura": 28.5,
    "ultima_umidade": 72.3,
    "alertas_ativos_count": 2,
    "sensores": [...],
    "recomendacao_atual": { "data_inicio": "2026-10-15", "data_fim": "2026-10-30", "grau_confianca": 0.87 }
  }
}
```

---

### 📡 Sensores

| Método  | Rota                         | Auth? | Descrição                          |
|---------|------------------------------|-------|------------------------------------|
| `GET`   | `/api/sensores`              | ✅    | Lista sensores (filtra por `lote_id`, `status`) |
| `POST`  | `/api/sensores`              | ✅    | Cadastra sensor manualmente        |
| `PATCH` | `/api/sensores/:id`          | ✅    | Atualiza sensor                    |
| `DELETE`| `/api/sensores/:id`          | ✅    | Remove sensor                      |
| `POST`  | `/api/sensores/leitura`      | ❌    | **Endpoint ESP-32** — sem autenticação |

> Ver seção [Integração ESP-32](#integração-esp-32) para detalhes do endpoint de leitura.

---

### 📊 Leituras de Sensores

| Método | Rota             | Descrição                                         |
|--------|------------------|---------------------------------------------------|
| `GET`  | `/api/leituras`  | Lista leituras. Filtros: `sensor_id`, `lote_id`, `limit` |
| `POST` | `/api/leituras`  | Cria leitura manualmente                          |

**Exportação CSV:**
```http
GET /api/leituras?format=csv
Authorization: Bearer abc123xyz...
```

Retorna um arquivo `.csv` com todas as leituras do usuário, pronto para Excel/Python.

---

### 🚨 Alertas

| Método  | Rota                        | Descrição                         |
|---------|-----------------------------|-----------------------------------|
| `GET`   | `/api/alertas`              | Lista alertas. Filtros: `resolvido=true/false`, `lote_id` |
| `PATCH` | `/api/alertas/:id/resolver` | Marca alerta como resolvido        |

**Resposta GET /api/alertas:**
```json
{
  "data": [...],
  "pendentes": 3,
  "total": 10
}
```

---

### 🤖 Recomendações de Colheita

| Método  | Rota                                | Descrição                             |
|---------|-------------------------------------|---------------------------------------|
| `GET`   | `/api/recomendacoes`                | Lista recomendações. Filtros: `lote_id`, `status` |
| `POST`  | `/api/recomendacoes/gerar`          | Dispara o motor de IA para gerar recomendações |
| `PATCH` | `/api/recomendacoes/:id/aceitar`    | Agricultor aceita a recomendação       |
| `PATCH` | `/api/recomendacoes/:id/rejeitar`   | Agricultor rejeita a recomendação      |

**Resposta POST /api/recomendacoes/gerar:**
```json
{
  "data": [
    {
      "id": 5,
      "lote_id": 1,
      "lote_nome": "L-001",
      "data_inicio": "2026-10-15",
      "data_fim": "2026-10-30",
      "grau_confianca": 0.87,
      "status": "pendente"
    }
  ],
  "total_geradas": 1
}
```

---

### 💰 Mercado

| Método | Rota           | Descrição                        |
|--------|----------------|----------------------------------|
| `GET`  | `/api/mercado` | Lista cotações e resumo por cultura |
| `POST` | `/api/mercado` | Registra nova cotação             |

**Exemplo POST:**
```json
{
  "cultura_id": 1,
  "preco_medio": 4.50,
  "moeda": "BRL",
  "data_cotacao": "2026-10-01"
}
```

---

### 🌦️ Clima

| Método | Rota         | Descrição                                |
|--------|--------------|------------------------------------------|
| `GET`  | `/api/clima` | Lista previsões. Filtro: `propriedade_id` |
| `POST` | `/api/clima` | Registra previsão climática              |

---

### 👥 Usuários

| Método  | Rota                  | Descrição           |
|---------|-----------------------|---------------------|
| `GET`   | `/api/usuarios`       | Lista usuários      |
| `GET`   | `/api/usuarios/:id`   | Detalhe do usuário  |
| `PATCH` | `/api/usuarios/:id`   | Atualiza perfil     |

---

### 📈 Dashboard

```http
GET /api/dashboard?propriedade_id=1
Authorization: Bearer abc123xyz...
```

**Resposta:**
```json
{
  "resumo": {
    "total_propriedades": 2,
    "total_lotes": 5,
    "area_monitorada_ha": 85.5,
    "total_sensores": 8,
    "sensores_ativos": 6,
    "alertas_pendentes_count": 3,
    "total_leituras": 1240
  },
  "ultima_leitura": { "temperatura": 28.5, "umidade": 72.3, "data_hora": "..." },
  "alertas_recentes": [...],
  "lotes": [...],
  "recomendacoes": [...],
  "previsao_clima": [...]
}
```

---

## Autenticação

O sistema usa **Bearer Token** estático gerado no momento do cadastro/login usando `SecureRandom.hex(32)`.

```
Authorization: Bearer <token>
```

O token é armazenado na coluna `api_token` da tabela `usuarios` e não expira automaticamente (é regenerado a cada login).

No frontend, o token é persistido em `localStorage` com a chave `hp_token`.

> O concern `Authenticatable` em `app/controllers/concerns/authenticatable.rb` centraliza a lógica de autenticação para todos os controllers.

---

## Integração ESP-32

### Endpoint de leitura (sem autenticação)

```
POST http://<IP_DO_SERVIDOR>:3333/api/sensores/leitura
Content-Type: application/json
```

**Payload:**
```json
{
  "codigo": "AA:BB:CC:DD:EE:FF",
  "temperatura": 28.5,
  "umidade": 72.3
}
```

**Comportamento:**
- Se o sensor com o `codigo` informado **não existir**, ele é **auto-registrado** como `sem_lote` e ativo
- Se existir, a leitura é registrada e o motor de alertas é executado automaticamente
- O motor verifica se temperatura/umidade estão dentro dos limites da cultura vinculada ao lote do sensor

**Resposta 201:**
```json
{
  "data": {
    "id": 42,
    "sensor_id": 3,
    "temperatura": 28.5,
    "umidade": 72.3,
    "data_hora": "2026-10-01T18:30:00.000Z"
  }
}
```

---

### Código de Firmware Arduino/C++ (ESP-32)

```cpp
#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <DHT.h>

// ——— Configurações ———
const char* SSID       = "SUA_REDE_WIFI";
const char* PASSWORD   = "SUA_SENHA_WIFI";
const char* SERVER_URL = "http://192.168.1.100:3333/api/sensores/leitura";
const char* SENSOR_MAC = "AA:BB:CC:DD:EE:FF"; // MAC do dispositivo

#define DHTPIN  4
#define DHTTYPE DHT22
DHT dht(DHTPIN, DHTTYPE);

void setup() {
  Serial.begin(115200);
  dht.begin();

  WiFi.begin(SSID, PASSWORD);
  Serial.print("Conectando ao WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  Serial.println("\nConectado! IP: " + WiFi.localIP().toString());
}

void loop() {
  float temperatura = dht.readTemperature();
  float umidade     = dht.readHumidity();

  if (isnan(temperatura) || isnan(umidade)) {
    Serial.println("Erro na leitura do DHT22");
    delay(10000);
    return;
  }

  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;
    http.begin(SERVER_URL);
    http.addHeader("Content-Type", "application/json");

    // Monta o JSON
    StaticJsonDocument<128> doc;
    doc["codigo"]      = SENSOR_MAC;
    doc["temperatura"] = temperatura;
    doc["umidade"]     = umidade;

    String payload;
    serializeJson(doc, payload);

    int httpCode = http.POST(payload);

    if (httpCode == 201) {
      Serial.printf("[OK] Leitura enviada: %.1f°C, %.1f%%\n", temperatura, umidade);
    } else {
      Serial.printf("[ERRO] HTTP %d\n", httpCode);
    }

    http.end();
  }

  delay(60000); // Envia a cada 60 segundos
}
```

> **Bibliotecas necessárias:** `WiFi.h` (built-in ESP32), `HTTPClient.h` (built-in ESP32), `ArduinoJson` (instalar via Library Manager), `DHT sensor library` (Adafruit).

---

## Arquitetura Interna

### Motor de Alertas Automáticos

Localizado em `app/models/leitura_sensor.rb`, após cada leitura salva:

1. Recupera a **cultura** associada ao lote do sensor
2. Compara `temperatura` e `umidade` com `temperatura_min/max` e `umidade_min/max` da cultura
3. Se fora do intervalo: cria um registro em `alertas` com `tipo` (`temperatura_alta`, `umidade_baixa`, etc.) e `severidade` (`aviso` ou `critico`)
4. Alertas duplicados (mesmo sensor, mesmo tipo, não resolvidos) não são criados novamente

### Motor de IA de Colheita (Heurística)

Localizado em `app/models/recomendacao_colheita.rb` e `app/controllers/api/recomendacoes_controller.rb`:

1. Para cada lote ativo com cultura definida:
   - Calcula `dias_decorridos` desde `data_plantio`
   - Obtém `ciclo_medio_dias` da cultura
   - Calcula `grau_confianca` com base em: progresso do ciclo, média de temperatura das últimas leituras, estabilidade da umidade, e dados climáticos da região
2. Cria/atualiza `recomendacao_colheita` com `data_inicio` e `data_fim` calculadas
3. O agricultor pode **aceitar** ou **rejeitar** a recomendação

### Modelos Rails

| Modelo                | Arquivo                                     |
|-----------------------|---------------------------------------------|
| `Usuario`             | `app/models/usuario.rb`                     |
| `User`                | `app/models/user.rb` _(alias para retrocompatibilidade)_ |
| `Propriedade`         | `app/models/propriedade.rb`                 |
| `Cultura`             | `app/models/cultura.rb`                     |
| `Lote`                | `app/models/lote.rb`                        |
| `HistoricoCultivo`    | `app/models/historico_cultivo.rb`           |
| `PrecoMercado`        | `app/models/preco_mercado.rb`               |
| `ClimaRegiao`         | `app/models/clima_regiao.rb`                |
| `Sensor`              | `app/models/sensor.rb`                      |
| `LeituraSensor`       | `app/models/leitura_sensor.rb`              |
| `Alerta`              | `app/models/alerta.rb` — método `resolver!` |
| `RecomendacaoColheita`| `app/models/recomendacao_colheita.rb` — métodos `aceitar!`, `rejeitar!` |

---

## Testes

### Executar todos os testes

```powershell
$env:RAILS_ENV = "test"
rails db:test:prepare
rails test
```

### Resultado esperado

```
30 tests, 100 assertions, 0 failures, 0 errors, 0 skips
```

### Arquivos de teste

| Arquivo                                          | Cobertura                                       |
|--------------------------------------------------|-------------------------------------------------|
| `test/integration/api_auth_test.rb`              | Cadastro, login, logout, token inválido         |
| `test/integration/api_lotes_test.rb`             | CRUD completo de lotes, validações              |
| `test/integration/api_routes_and_robustness_test.rb` | Rotas, CORS, payloads inválidos, 404/422    |
| `test/integration/api_iot_esp32_and_complete_schema_test.rb` | Endpoint ESP-32, auto-registro sensor, alertas, recomendações |

---

## Estrutura de Diretórios

```
Backend/harvestpoint/
├── app/
│   ├── controllers/
│   │   └── api/
│   │       ├── auth/               # registrations, sessions
│   │       ├── alertas_controller.rb
│   │       ├── dashboard_controller.rb
│   │       ├── lotes_controller.rb
│   │       ├── recomendacoes_controller.rb
│   │       ├── sensores_controller.rb
│   │       └── ...
│   ├── models/
│   │   ├── leitura_sensor.rb       # Motor de alertas
│   │   ├── recomendacao_colheita.rb # Motor de IA
│   │   └── ...
│   └── controllers/concerns/
│       └── authenticatable.rb      # Autenticação via Bearer Token
├── config/
│   ├── routes.rb
│   ├── database.yml
│   └── initializers/cors.rb        # CORS configurado para localhost:5173
├── db/
│   ├── migrate/
│   ├── schema.rb
│   └── seeds.rb
└── test/
    └── integration/
```

---

## CORS

O CORS está configurado em `config/initializers/cors.rb` para aceitar requisições de `http://localhost:5173` (Vite dev server) em todos os ambientes de desenvolvimento.

Para produção, altere as origens permitidas conforme o domínio do frontend.
