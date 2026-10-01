require "test_helper"

class Api::IotEsp32AndCompleteSchemaTest < ActionDispatch::IntegrationTest
  setup do
    @user = Usuario.create!(
      nome: "Abraao Freitas",
      email: "abraao@boavista.agro.br",
      password: "senha1234",
      tipo_usuario: "PRODUTOR",
      cpf_cnpj: "123.456.789-00",
      telefone: "(87) 98822-1122"
    )
    @propriedade = @user.propriedades.create!(
      nome: "Fazenda Boa Vista",
      municipio: "Petrolina - PE",
      latitude: -9.3891,
      longitude: -40.5027,
      area_total: 250.0
    )
    @cultura = Cultura.create!(
      nome: "Manga Palmer",
      ciclo_medio_dias: 120,
      temperatura_min: 22.0,
      temperatura_max: 35.0,
      umidade_min: 40.0,
      umidade_max: 70.0
    )
    @lote = @propriedade.lotes.create!(
      nome: "Lote A1 - Manga",
      area: 85.0
    )
    @historico = HistoricoCultivo.create!(
      lote: @lote,
      cultura: @cultura,
      data_plantio: 100.days.ago.to_date,
      status: "ATIVO"
    )
    @sensor = @lote.sensores.create!(
      codigo: "24:6F:28:AB:CD:EF",
      status: "ATIVO"
    )
    @token = @user.issue_api_token!
    @headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "ESP-32 envia leitura de temperatura e umidade com sucesso" do
    assert_difference("LeituraSensor.count", 1) do
      post "/api/sensores/leitura", params: {
        codigo: @sensor.codigo,
        temperatura: 31.5,
        umidade: 55.0
      }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "success", body["status"]
    assert_equal 31.5, body.dig("data", "leitura", "temperatura")
    assert_equal 55.0, body.dig("data", "leitura", "umidade")
  end

  test "ESP-32 envia temperatura acima do limite e gera alerta automaticamente" do
    assert_difference("Alerta.count", 1) do
      post "/api/sensores/leitura", params: {
        codigo: @sensor.codigo,
        temperatura: 38.0, # acima do maximo de 35.0 da Manga
        umidade: 50.0
      }, as: :json
    end

    assert_response :created
    alerta = Alerta.last
    assert_equal "TEMPERATURA_ALTA", alerta.tipo
    assert_equal false, alerta.resolvido
    assert_includes alerta.mensagem, "38.0°C"
  end

  test "ESP-32 envia estresse hidrico e gera alerta" do
    assert_difference("Alerta.count", 1) do
      post "/api/sensores/leitura", params: {
        codigo: @sensor.codigo,
        temperatura: 30.0,
        umidade: 32.0 # abaixo do minimo de 40.0
      }, as: :json
    end

    assert_response :created
    alerta = Alerta.last
    assert_equal "ESTRESSE_HIDRICO", alerta.tipo
    assert_equal false, alerta.resolvido
  end

  test "resolver alerta pendente" do
    alerta = @sensor.alertas.create!(
      tipo: "AVISO_CALOR",
      mensagem: "Calor intenso",
      data_hora: Time.current,
      resolvido: false
    )

    patch "/api/alertas/#{alerta.id}/resolver", headers: @headers, as: :json
    assert_response :ok
    assert_equal true, alerta.reload.resolvido
  end

  test "inteligencia artificial gera e aceita recomendacao de colheita" do
    post "/api/recomendacoes/gerar", headers: @headers, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert body["total_geradas"] >= 1

    rec = RecomendacaoColheita.last
    assert_equal "PENDENTE", rec.status
    assert rec.grau_confianca > 80.0

    patch "/api/recomendacoes/#{rec.id}/aceitar", headers: @headers, as: :json
    assert_response :ok
    assert_equal "ACEITA", rec.reload.status
  end

  test "exportacao de leituras em CSV" do
    @sensor.leitura_sensores.create!(
      temperatura: 30.0,
      umidade: 60.0,
      data_hora: Time.current
    )

    get "/api/leituras?format=csv", headers: @headers
    assert_response :ok
    assert_includes response.body, "Sensor (MAC)"
    assert_includes response.body, "24:6F:28:AB:CD:EF"
  end

  test "dashboard retorna estatisticas integradas" do
    get "/api/dashboard", headers: @headers, as: :json
    assert_response :ok
    body = JSON.parse(response.body)
    assert body.dig("resumo", "total_lotes") >= 1
    assert body.dig("resumo", "total_sensores") >= 1
  end
end
