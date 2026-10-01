puts "==> Semeando banco de dados do HarvestPoint (Vale do São Francisco)..."

# Limpa dados anteriores
RecomendacaoColheita.destroy_all
Alerta.destroy_all
LeituraSensor.destroy_all
Sensor.destroy_all
HistoricoCultivo.destroy_all
PrecoMercado.destroy_all
ClimaRegiao.destroy_all
Lote.destroy_all
Propriedade.destroy_all
Cultura.destroy_all
Usuario.destroy_all

# 1. USUARIOS
produtor = Usuario.create!(
  nome: "Abraão Freitas",
  email: "abraao@boavista.agro.br",
  password: "senha1234",
  cpf_cnpj: "123.456.789-00",
  telefone: "(87) 98822-1122",
  tipo_usuario: "PRODUTOR",
  data_cadastro: 6.months.ago
)

tecnico = Usuario.create!(
  nome: "Maria Silva",
  email: "maria@fazenda.com",
  password: "senha1234",
  cpf_cnpj: "987.654.321-11",
  telefone: "(87) 99911-3344",
  tipo_usuario: "TECNICO",
  data_cadastro: 4.months.ago
)

# 2. PROPRIEDADES
boa_vista = Propriedade.create!(
  usuario: produtor,
  nome: "Fazenda Boa Vista",
  municipio: "Petrolina - PE",
  latitude: -9.3891440,
  longitude: -40.5027110,
  area_total: 250.00
)

mandacaru = Propriedade.create!(
  usuario: produtor,
  nome: "Sítio Mandacaru",
  municipio: "Juazeiro - BA",
  latitude: -9.4166670,
  longitude: -40.5033330,
  area_total: 120.00
)

# 3. CULTURAS
manga = Cultura.create!(
  nome: "Manga Palmer",
  ciclo_medio_dias: 120,
  temperatura_min: 22.0,
  temperatura_max: 36.0,
  umidade_min: 40.0,
  umidade_max: 70.0
)

uva = Cultura.create!(
  nome: "Uva Thompson",
  ciclo_medio_dias: 110,
  temperatura_min: 20.0,
  temperatura_max: 33.0,
  umidade_min: 45.0,
  umidade_max: 65.0
)

maracuja = Cultura.create!(
  nome: "Maracujá Amarelo",
  ciclo_medio_dias: 180,
  temperatura_min: 21.0,
  temperatura_max: 35.0,
  umidade_min: 50.0,
  umidade_max: 80.0
)

# 4. LOTES
lote_a1 = Lote.create!(
  propriedade: boa_vista,
  nome: "Lote A1 - Manga",
  area: 85.00
)

lote_b2 = Lote.create!(
  propriedade: boa_vista,
  nome: "Lote B2 - Uva",
  area: 65.00
)

lote_c3 = Lote.create!(
  propriedade: mandacaru,
  nome: "Lote C3 - Maracujá",
  area: 40.00
)

# 5. HISTORICO CULTIVO
HistoricoCultivo.create!(
  lote: lote_a1,
  cultura: manga,
  data_plantio: 98.days.ago.to_date,
  status: "ATIVO"
)

HistoricoCultivo.create!(
  lote: lote_b2,
  cultura: uva,
  data_plantio: 76.days.ago.to_date,
  status: "ATIVO"
)

HistoricoCultivo.create!(
  lote: lote_c3,
  cultura: maracuja,
  data_plantio: 155.days.ago.to_date,
  status: "ATIVO"
)

# 6. PRECO MERCADO
PrecoMercado.create!(cultura: manga, preco_medio: 16.80, moeda: "BRL", data_cotacao: Date.current)
PrecoMercado.create!(cultura: manga, preco_medio: 2.80, moeda: "EUR", data_cotacao: Date.current)
PrecoMercado.create!(cultura: uva, preco_medio: 18.50, moeda: "BRL", data_cotacao: Date.current)
PrecoMercado.create!(cultura: uva, preco_medio: 3.20, moeda: "USD", data_cotacao: Date.current)
PrecoMercado.create!(cultura: maracuja, preco_medio: 9.40, moeda: "BRL", data_cotacao: Date.current)

# 7. CLIMA REGIAO (Macroclima)
(0..4).each do |offset|
  dia = Date.current + offset.days
  ClimaRegiao.create!(
    propriedade: boa_vista,
    data_previsao: dia,
    temperatura_min: 23.0 + rand(-1.0..1.0).round(1),
    temperatura_max: 35.5 + rand(-1.5..1.5).round(1),
    chance_chuva_percentual: offset == 3 ? 45.0 : 10.0,
    precipitacao_mm: offset == 3 ? 5.2 : 0.0
  )
  ClimaRegiao.create!(
    propriedade: mandacaru,
    data_previsao: dia,
    temperatura_min: 24.0 + rand(-1.0..1.0).round(1),
    temperatura_max: 36.0 + rand(-1.5..1.5).round(1),
    chance_chuva_percentual: 5.0,
    precipitacao_mm: 0.0
  )
end

# 8. SENSORES (Dispositivos IoT ESP-32)
sensor1 = Sensor.create!(
  lote: lote_a1,
  codigo: "24:6F:28:AB:CD:01",
  status: "ATIVO"
)

sensor2 = Sensor.create!(
  lote: lote_b2,
  codigo: "24:6F:28:AB:CD:02",
  status: "ATIVO"
)

sensor3 = Sensor.create!(
  lote: lote_c3,
  codigo: "24:6F:28:AB:CD:03",
  status: "ATIVO"
)

# 9. LEITURA SENSOR (Série temporal de leituras)
base_time = 12.hours.ago
12.times do |i|
  hora = base_time + (i * 1.hour)
  LeituraSensor.create!(
    sensor: sensor1,
    data_hora: hora,
    temperatura: (30.0 + (i % 5) * 0.8).round(1),
    umidade: (55.0 - (i % 4) * 2.0).round(1)
  )
  LeituraSensor.create!(
    sensor: sensor2,
    data_hora: hora,
    temperatura: (27.5 + (i % 4) * 0.7).round(1),
    umidade: (58.0 - (i % 5) * 1.5).round(1)
  )
  LeituraSensor.create!(
    sensor: sensor3,
    data_hora: hora,
    temperatura: (31.0 + (i % 3) * 0.9).round(1),
    umidade: (52.0 - (i % 3) * 2.5).round(1)
  )
end

# Leitura recente fora de faixa para gerar alerta no Lote A1
LeituraSensor.create!(
  sensor: sensor1,
  data_hora: 10.minutes.ago,
  temperatura: 37.5, # Acima do limite de 36.0
  umidade: 36.0      # Abaixo do limite de 40.0
)

# 10. RECOMENDAÇÃO COLHEITA
RecomendacaoColheita.create!(
  lote: lote_a1,
  data_inicio: Date.current + 18.days,
  data_fim: Date.current + 25.days,
  grau_confianca: 94.50,
  data_atualizacao: Time.current,
  status: "PENDENTE"
)

RecomendacaoColheita.create!(
  lote: lote_c3,
  data_inicio: Date.current + 8.days,
  data_fim: Date.current + 15.days,
  grau_confianca: 91.20,
  data_atualizacao: Time.current,
  status: "ACEITA"
)

puts "==> Semeado com sucesso! Usuários, propriedades, culturas, lotes, sensores ESP-32, leituras e recomendações configurados."
