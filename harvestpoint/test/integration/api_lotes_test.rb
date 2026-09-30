require "test_helper"

class Api::LotesTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      nome: "Abraao Freitas",
      email: "abraao@boavista.agro.br",
      password: "senha1234",
      role: "proprietario",
      propriedade: "Fazenda Boa Vista"
    )
    @other = User.create!(
      nome: "Outro",
      email: "outro@fazenda.com",
      password: "senha1234",
      role: "tecnico",
      propriedade: "Outra Fazenda"
    )
    @token = @user.issue_api_token!
    @headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "criar lote" do
    assert_difference("Lote.count", 1) do
      post "/api/lotes", params: lote_payload, headers: @headers, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Lote A1", body.dig("data", "codigo")
    assert_equal @user.id, Lote.last.user_id
  end

  test "listar lotes" do
    @user.lotes.create!(lote_attributes)
    @other.lotes.create!(lote_attributes.merge(codigo: "Lote Z9", propriedade: "Outra Fazenda"))

    get "/api/lotes", headers: @headers, as: :json

    assert_response :ok
    data = JSON.parse(response.body)["data"]
    assert_equal 1, data.length
    assert_equal "Lote A1", data.first["codigo"]
  end

  test "buscar lote especifico" do
    lote = @user.lotes.create!(lote_attributes)

    get "/api/lotes/#{lote.id}", headers: @headers, as: :json

    assert_response :ok
    assert_equal lote.id, JSON.parse(response.body).dig("data", "id")
  end

  test "atualizar lote" do
    lote = @user.lotes.create!(lote_attributes)

    patch "/api/lotes/#{lote.id}", params: { status: "em_manejo", area_ha: 90 }, headers: @headers, as: :json

    assert_response :ok
    assert_equal "em_manejo", JSON.parse(response.body).dig("data", "status")
    assert_equal 90.0, JSON.parse(response.body).dig("data", "area_ha")
  end

  test "excluir lote" do
    lote = @user.lotes.create!(lote_attributes)

    assert_difference("Lote.count", -1) do
      delete "/api/lotes/#{lote.id}", headers: @headers, as: :json
    end

    assert_response :ok
  end

  test "lote inexistente" do
    get "/api/lotes/999999", headers: @headers, as: :json

    assert_response :not_found
    assert_equal "not_found", JSON.parse(response.body)["error"]
  end

  test "dados invalidos" do
    post "/api/lotes", params: lote_payload.merge(codigo: "", area_ha: -1, status: "xyz"), headers: @headers, as: :json

    assert_response :unprocessable_content
    assert_equal "invalid_data", JSON.parse(response.body)["error"]
  end

  test "nao acessa lote de outro usuario" do
    lote = @other.lotes.create!(lote_attributes.merge(codigo: "Lote Z9"))

    get "/api/lotes/#{lote.id}", headers: @headers, as: :json

    assert_response :not_found
  end

  test "lotes exigem autenticacao" do
    get "/api/lotes", as: :json

    assert_response :unauthorized
  end

  private

  def lote_attributes
    {
      codigo: "Lote A1",
      propriedade: "Fazenda Boa Vista",
      cultura: "Manga",
      variedade: "Tommy Atkins",
      area_ha: 120,
      data_plantio: Date.new(2024, 3, 15),
      sensor_vinculado: "IOT-001",
      status: "ativo"
    }
  end

  def lote_payload
    lote_attributes.merge(data_plantio: "2024-03-15")
  end
end
