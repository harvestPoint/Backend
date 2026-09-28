require "test_helper"

class RecomendacaoColheitaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @recomendacao_colheitum = recomendacao_colheita(:one)
  end

  test "should get index" do
    get recomendacao_colheita_url, as: :json
    assert_response :success
  end

  test "should create recomendacao_colheitum" do
    assert_difference("RecomendacaoColheitum.count") do
      post recomendacao_colheita_url, params: { recomendacao_colheitum: { data_recomendacao: @recomendacao_colheitum.data_recomendacao, expectativa_produtividade: @recomendacao_colheitum.expectativa_produtividade, lote_id: @recomendacao_colheitum.lote_id, observacoes: @recomendacao_colheitum.observacoes, status: @recomendacao_colheitum.status } }, as: :json
    end

    assert_response :created
  end

  test "should show recomendacao_colheitum" do
    get recomendacao_colheitum_url(@recomendacao_colheitum), as: :json
    assert_response :success
  end

  test "should update recomendacao_colheitum" do
    patch recomendacao_colheitum_url(@recomendacao_colheitum), params: { recomendacao_colheitum: { data_recomendacao: @recomendacao_colheitum.data_recomendacao, expectativa_produtividade: @recomendacao_colheitum.expectativa_produtividade, lote_id: @recomendacao_colheitum.lote_id, observacoes: @recomendacao_colheitum.observacoes, status: @recomendacao_colheitum.status } }, as: :json
    assert_response :success
  end

  test "should destroy recomendacao_colheitum" do
    assert_difference("RecomendacaoColheitum.count", -1) do
      delete recomendacao_colheitum_url(@recomendacao_colheitum), as: :json
    end

    assert_response :no_content
  end
end
