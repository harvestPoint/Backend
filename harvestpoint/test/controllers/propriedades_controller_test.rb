require "test_helper"

class PropriedadesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @propriedade = propriedades(:one)
  end

  test "should get index" do
    get propriedades_url, as: :json
    assert_response :success
  end

  test "should create propriedade" do
    assert_difference("Propriedade.count") do
      post propriedades_url, params: { propriedade: { area_total: @propriedade.area_total, localizacao: @propriedade.localizacao, municipio: @propriedade.municipio, nome: @propriedade.nome, usuario_id: @propriedade.usuario_id } }, as: :json
    end

    assert_response :created
  end

  test "should show propriedade" do
    get propriedade_url(@propriedade), as: :json
    assert_response :success
  end

  test "should update propriedade" do
    patch propriedade_url(@propriedade), params: { propriedade: { area_total: @propriedade.area_total, localizacao: @propriedade.localizacao, municipio: @propriedade.municipio, nome: @propriedade.nome, usuario_id: @propriedade.usuario_id } }, as: :json
    assert_response :success
  end

  test "should destroy propriedade" do
    assert_difference("Propriedade.count", -1) do
      delete propriedade_url(@propriedade), as: :json
    end

    assert_response :no_content
  end
end
