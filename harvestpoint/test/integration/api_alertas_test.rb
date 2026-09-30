require "test_helper"

class Api::AlertasTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(nome: "Abraao Freitas", email: "abraao@boavista.agro.br",
                          password: "senha1234", propriedade: "Fazenda Boa Vista")
    @lote = @user.lotes.create!(codigo: "A1", propriedade: "Fazenda Boa Vista", cultura: "Manga",
                                 variedade: "Espada", area_ha: 120)
    @sensor = @user.sensores.create!(codigo: "IOT-001", lote: @lote)
    Cultura.find_or_create_by!(nome: "Manga", variedade: "Espada") do |c|
      c.assign_attributes(temperatura_min: 22, temperatura_max: 30, ciclo_dias: 120)
    end
    @token = @user.issue_api_token!
    @headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "lista apenas alertas ativos por padrao" do
    post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 31.9 }, headers: @headers, as: :json

    get "/api/alertas", headers: @headers, as: :json

    assert_response :ok
    dados = JSON.parse(response.body)["data"]
    assert_equal 1, dados.length
    assert_equal "aberto", dados.first["status"]
  end

  test "resolve alerta manualmente" do
    post "/api/leituras", params: { sensor_id: @sensor.id, temperatura: 31.9 }, headers: @headers, as: :json
    alerta_id = Alerta.last.id

    patch "/api/alertas/#{alerta_id}", params: { status: "resolvido" }, headers: @headers, as: :json

    assert_response :ok
    body = JSON.parse(response.body)["data"]
    assert_equal "resolvido", body["status"]
    assert body["resolvido_em"].present?
  end

  test "nao acessa alerta de outro usuario" do
    outro = User.create!(nome: "Outro", email: "outro@fazenda.com", password: "senha1234", propriedade: "Outra")
    lote = outro.lotes.create!(codigo: "Z9", propriedade: "Outra", cultura: "Manga", variedade: "Espada", area_ha: 5)
    sensor = outro.sensores.create!(codigo: "IOT-Z9", lote: lote)
    outro_token = outro.issue_api_token!
    post "/api/leituras", params: { sensor_id: sensor.id, temperatura: 31.9 },
      headers: { "Authorization" => "Bearer #{outro_token}" }, as: :json
    alerta_id = Alerta.last.id

    get "/api/alertas/#{alerta_id}", headers: @headers, as: :json

    assert_response :not_found
  end
end
