require "test_helper"

class Api::RoutesAndRobustnessTest < ActionDispatch::IntegrationTest
  setup do
    @password = "senha1234"
    @user = User.create!(
      nome: "Abraao Freitas",
      email: "abraao@boavista.agro.br",
      password: @password,
      role: "proprietario",
      propriedade: "Fazenda Boa Vista"
    )
    @token = @user.issue_api_token!
    @headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "rotas diretas de login e signup sem prefixo /api" do
    post "/login", params: { email: @user.email, senha: @password }, as: :json
    assert_response :ok
    assert JSON.parse(response.body).dig("data", "token").present?

    post "/signup", params: {
      nome: "Novo Usuario",
      email: "novo@agro.com",
      senha: "senha1234",
      propriedade: "Fazenda Nova"
    }, as: :json
    assert_response :created
    assert_equal "proprietario", JSON.parse(response.body).dig("data", "user", "role")
  end

  test "rotas diretas de lotes sem prefixo /api" do
    post "/lotes", params: {
      codigo: "Lote Direto",
      cultura: "Manga",
      variedade: "Palmer",
      area_ha: "45,5"
    }, headers: @headers, as: :json
    assert_response :created
    lote_id = JSON.parse(response.body).dig("data", "id")
    assert_equal 45.5, JSON.parse(response.body).dig("data", "area_ha")
    assert_equal "Fazenda Boa Vista", JSON.parse(response.body).dig("data", "propriedade")

    get "/lotes", headers: @headers, as: :json
    assert_response :ok

    get "/lotes/#{lote_id}", headers: @headers, as: :json
    assert_response :ok

    patch "/lotes/#{lote_id}", params: { status: "em_manejo" }, headers: @headers, as: :json
    assert_response :ok
    assert_equal "em_manejo", JSON.parse(response.body).dig("data", "status")

    delete "/lotes/#{lote_id}", headers: @headers, as: :json
    assert_response :ok
  end

  test "login com campos em branco retorna erro amigavel" do
    post "/api/auth/login", params: { email: "", senha: "" }, as: :json
    assert_response :unauthorized
    body = JSON.parse(response.body)
    assert_equal "invalid_credentials", body["error"]
  end

  test "login aceita chave user aninhada ou plana" do
    post "/api/auth/login", params: { user: { email: @user.email, password: @password } }, as: :json
    assert_response :ok
    assert JSON.parse(response.body).dig("data", "token").present?
  end

  test "suporte a cabecalho Authorization com bearer minusculo" do
    get "/api/auth/me", headers: { "Authorization" => "bearer #{@token}" }, as: :json
    assert_response :ok
    assert_equal @user.email, JSON.parse(response.body).dig("data", "user", "email")
  end
end
