require "test_helper"

class Api::LeiturasTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(nome: "Abraao Freitas", email: "abraao@boavista.agro.br",
                          password: "senha1234", propriedade: "Fazenda Boa Vista")
    @lote = @user.lotes.create!(codigo: "A1", propriedade: "Fazenda Boa Vista", cultura: "Manga",
                                 variedade: "Espada", area_ha: 120)
    @sensor = @user.sensores.create!(codigo: "IOT-001", lote: @lote)
    @token = @user.issue_api_token!
    @headers = { "Authorization" => "Bearer #{@token}" }
    Cultura.find_or_create_by!(nome: "Manga", variedade: "Espada") do |c|
      c.assign_attributes(temperatura_min: 22, temperatura_max: 30, ciclo_dias: 120)
    end
  end

  test "usuario autenticado registra leitura do proprio sensor" do
    assert_difference("Leitura.count", 1) do
      post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 31.9 }, headers: @headers, as: :json
    end

    assert_response :created
    assert_equal 31.9, JSON.parse(response.body).dig("data", "temperatura")
  end

  test "dispositivo registra leitura com o token do sensor, sem sessao de usuario" do
    assert_difference("Leitura.count", 1) do
      post "/api/leituras",
        params: { temperatura: 24.5, umidade_ar: 70 },
        headers: { "X-Sensor-Token" => @sensor.token }, as: :json
    end

    assert_response :created
  end

  test "token de sensor invalido e rejeitado" do
    post "/api/leituras", params: { temperatura: 24.5 }, headers: { "X-Sensor-Token" => "invalido" }, as: :json

    assert_response :unauthorized
  end

  test "leitura acima do limite abre alerta automaticamente" do
    assert_difference("Alerta.count", 1) do
      post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 31.9 }, headers: @headers, as: :json
    end

    alerta = Alerta.last
    assert_equal "critico", alerta.severidade
    assert_equal "temperatura", alerta.grandeza
    assert_equal "acima", alerta.direcao
  end

  test "leitura de volta a faixa ideal resolve o alerta aberto" do
    post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 31.9 }, headers: @headers, as: :json
    assert_equal "aberto", Alerta.last.status

    post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 25.0 }, headers: @headers, as: :json

    assert_equal "resolvido", Alerta.last.reload.status
  end

  test "leitura sem nenhuma medida e invalida" do
    post "/api/leituras", params: { sensor_id: @sensor.id }, headers: @headers, as: :json

    assert_response :unprocessable_content
  end

  test "leituras exigem autenticacao ou token de sensor" do
    post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 20 }, as: :json

    assert_response :unauthorized
  end
end
