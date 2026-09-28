require "test_helper"

class CulturasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @cultura = culturas(:one)
  end

  test "should get index" do
    get culturas_url, as: :json
    assert_response :success
  end

  test "should create cultura" do
    assert_difference("Cultura.count") do
      post culturas_url, params: { cultura: { ciclo_medio_dias: @cultura.ciclo_medio_dias, descricao: @cultura.descricao, nome: @cultura.nome, temperatura_max: @cultura.temperatura_max, temperatura_min: @cultura.temperatura_min, umidade_max: @cultura.umidade_max, umidade_min: @cultura.umidade_min } }, as: :json
    end

    assert_response :created
  end

  test "should show cultura" do
    get cultura_url(@cultura), as: :json
    assert_response :success
  end

  test "should update cultura" do
    patch cultura_url(@cultura), params: { cultura: { ciclo_medio_dias: @cultura.ciclo_medio_dias, descricao: @cultura.descricao, nome: @cultura.nome, temperatura_max: @cultura.temperatura_max, temperatura_min: @cultura.temperatura_min, umidade_max: @cultura.umidade_max, umidade_min: @cultura.umidade_min } }, as: :json
    assert_response :success
  end

  test "should destroy cultura" do
    assert_difference("Cultura.count", -1) do
      delete cultura_url(@cultura), as: :json
    end

    assert_response :no_content
  end
end
