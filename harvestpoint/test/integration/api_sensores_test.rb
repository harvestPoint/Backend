require "test_helper"

class Api::SensoresTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(nome: "Abraao Freitas", email: "abraao@boavista.agro.br",
                          password: "senha1234", propriedade: "Fazenda Boa Vista")
    @other = User.create!(nome: "Outro", email: "outro@fazenda.com",
                           password: "senha1234", propriedade: "Outra Fazenda")
    @lote = @user.lotes.create!(codigo: "A1", propriedade: "Fazenda Boa Vista", cultura: "Manga",
                                 variedade: "Espada", area_ha: 120)
    @token = @user.issue_api_token!
    @headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "cria sensor e devolve o token do dispositivo" do
    assert_difference("Sensor.count", 1) do
      post "/api/sensores",
        params: { codigo: "IOT-001", lote_id: @lote.id, grandezas: %w[temperatura umidade_ar] },
        headers: @headers, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)["data"]
    assert_equal "IOT-001", body["codigo"]
    assert body["token"].present?
  end

  test "nao lista nem devolve token na listagem" do
    @user.sensores.create!(codigo: "IOT-001")

    get "/api/sensores", headers: @headers, as: :json

    assert_response :ok
    body = JSON.parse(response.body)["data"].first
    assert_nil body["token"]
  end

  test "status on-line depende da ultima leitura" do
    sensor = @user.sensores.create!(codigo: "IOT-001", ultima_leitura_em: 1.hour.ago)
    assert_equal "on-line", sensor.status_operacional

    sensor.update!(ultima_leitura_em: 6.hours.ago)
    assert_equal "instável", sensor.status_operacional

    sensor.update!(ultima_leitura_em: nil)
    assert_equal "off-line", sensor.status_operacional
  end

  test "nao aceita lote de outro usuario" do
    lote_alheio = @other.lotes.create!(codigo: "Z9", propriedade: "Outra Fazenda", cultura: "Uva",
                                        variedade: "Núbia", area_ha: 10)

    post "/api/sensores", params: { codigo: "IOT-009", lote_id: lote_alheio.id }, headers: @headers, as: :json

    assert_response :not_found
  end

  test "nao acessa sensor de outro usuario" do
    sensor = @other.sensores.create!(codigo: "IOT-009")

    get "/api/sensores/#{sensor.id}", headers: @headers, as: :json

    assert_response :not_found
  end
end
