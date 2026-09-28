require "test_helper"

class UsuariosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @usuario = usuarios(:one)
  end

  test "should get index" do
    get usuarios_url, as: :json
    assert_response :success
  end

  test "should create usuario" do
    assert_difference("Usuario.count") do
      post usuarios_url, params: { usuario: { cpf_cnpj: @usuario.cpf_cnpj, data_cadastro: @usuario.data_cadastro, email: @usuario.email, nome: @usuario.nome, senha_hash: @usuario.senha_hash, telefone: @usuario.telefone, tipo_usuario: @usuario.tipo_usuario } }, as: :json
    end

    assert_response :created
  end

  test "should show usuario" do
    get usuario_url(@usuario), as: :json
    assert_response :success
  end

  test "should update usuario" do
    patch usuario_url(@usuario), params: { usuario: { cpf_cnpj: @usuario.cpf_cnpj, data_cadastro: @usuario.data_cadastro, email: @usuario.email, nome: @usuario.nome, senha_hash: @usuario.senha_hash, telefone: @usuario.telefone, tipo_usuario: @usuario.tipo_usuario } }, as: :json
    assert_response :success
  end

  test "should destroy usuario" do
    assert_difference("Usuario.count", -1) do
      delete usuario_url(@usuario), as: :json
    end

    assert_response :no_content
  end
end
