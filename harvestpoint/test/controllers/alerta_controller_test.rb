require "test_helper"

class AlertaControllerTest < ActionDispatch::IntegrationTest
  setup do
    @alertum = alerta(:one)
  end

  test "should get index" do
    get alerta_url, as: :json
    assert_response :success
  end

  test "should create alertum" do
    assert_difference("Alertum.count") do
      post alerta_url, params: { alertum: { data_hora: @alertum.data_hora, lote_id: @alertum.lote_id, mensagem: @alertum.mensagem, resolvido: @alertum.resolvido, sensor_id: @alertum.sensor_id, tipo_alerta: @alertum.tipo_alerta } }, as: :json
    end

    assert_response :created
  end

  test "should show alertum" do
    get alertum_url(@alertum), as: :json
    assert_response :success
  end

  test "should update alertum" do
    patch alertum_url(@alertum), params: { alertum: { data_hora: @alertum.data_hora, lote_id: @alertum.lote_id, mensagem: @alertum.mensagem, resolvido: @alertum.resolvido, sensor_id: @alertum.sensor_id, tipo_alerta: @alertum.tipo_alerta } }, as: :json
    assert_response :success
  end

  test "should destroy alertum" do
    assert_difference("Alertum.count", -1) do
      delete alertum_url(@alertum), as: :json
    end

    assert_response :no_content
  end
end
