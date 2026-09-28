require "test_helper"

class Api::AuthTest < ActionDispatch::IntegrationTest
  setup do
    @password = "senha1234"
    @user = User.create!(
      nome: "Abraao Freitas",
      email: "abraao@boavista.agro.br",
      password: @password,
      role: "proprietario",
      propriedade: "Fazenda Boa Vista"
    )
  end

  test "cadastro valido" do
    assert_difference("User.count", 1) do
      post "/api/auth/signup", params: {
        nome: "Maria Silva",
        email: "maria@fazenda.com",
        senha: "senha1234",
        role: "tecnico",
        propriedade: "Fazenda Boa Vista"
      }, as: :json
    end

    assert_response :created
    body = JSON.parse(response.body)
    assert_equal "Cadastro realizado", body["message"]
    assert body.dig("data", "token").present?
    assert_equal "Maria Silva", body.dig("data", "user", "nome")
    assert_nil body.dig("data", "user", "password_digest")
    assert_nil body.dig("data", "user", "senha")
  end

  test "cadastro invalido" do
    post "/api/auth/signup", params: {
      nome: "",
      email: "nao-e-email",
      senha: "123",
      role: "admin",
      propriedade: ""
    }, as: :json

    assert_response :unprocessable_content
    body = JSON.parse(response.body)
    assert_equal "invalid_data", body["error"]
  end

  test "cadastro duplicado" do
    post "/api/auth/signup", params: {
      nome: "Outro",
      email: @user.email,
      senha: "senha1234",
      role: "proprietario",
      propriedade: "Fazenda Boa Vista"
    }, as: :json

    assert_response :conflict
    assert_equal "user_already_exists", JSON.parse(response.body)["error"]
  end

  test "login valido" do
    post "/api/auth/login", params: { email: @user.email, senha: @password }, as: :json

    assert_response :ok
    body = JSON.parse(response.body)
    assert body.dig("data", "token").present?
    assert_equal @user.email, body.dig("data", "user", "email")
    assert_nil body.dig("data", "user", "password_digest")
  end

  test "login usuario inexistente" do
    post "/api/auth/login", params: { email: "naoexiste@fazenda.com", senha: @password }, as: :json

    assert_response :unauthorized
    assert_equal "user_not_found", JSON.parse(response.body)["error"]
  end

  test "login credenciais invalidas" do
    post "/api/auth/login", params: { email: @user.email, senha: "errada999" }, as: :json

    assert_response :unauthorized
    assert_equal "invalid_credentials", JSON.parse(response.body)["error"]
  end

  test "requisicao protegida sem autenticacao" do
    get "/api/auth/me", as: :json

    assert_response :unauthorized
    assert_equal "unauthenticated", JSON.parse(response.body)["error"]
  end

  test "requisicao protegida autenticada" do
    token = @user.issue_api_token!
    get "/api/auth/me", headers: { "Authorization" => "Bearer #{token}" }, as: :json

    assert_response :ok
    assert_equal @user.email, JSON.parse(response.body).dig("data", "user", "email")
  end

  test "logout invalida o token" do
    token = @user.issue_api_token!
    delete "/api/auth/logout", headers: { "Authorization" => "Bearer #{token}" }, as: :json

    assert_response :ok
    get "/api/auth/me", headers: { "Authorization" => "Bearer #{token}" }, as: :json
    assert_response :unauthorized
  end
end
