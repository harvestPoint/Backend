require "test_helper"

class SensorsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sensor = sensors(:one)
  end

  test "should get index" do
    get sensors_url, as: :json
    assert_response :success
  end

  test "should create sensor" do
    assert_difference("Sensor.count") do
      post sensors_url, params: { sensor: { data_instalacao: @sensor.data_instalacao, lote_id: @sensor.lote_id, status: @sensor.status, tipo: @sensor.tipo, unidade_medida: @sensor.unidade_medida } }, as: :json
    end

    assert_response :created
  end

  test "should show sensor" do
    get sensor_url(@sensor), as: :json
    assert_response :success
  end

  test "should update sensor" do
    patch sensor_url(@sensor), params: { sensor: { data_instalacao: @sensor.data_instalacao, lote_id: @sensor.lote_id, status: @sensor.status, tipo: @sensor.tipo, unidade_medida: @sensor.unidade_medida } }, as: :json
    assert_response :success
  end

  test "should destroy sensor" do
    assert_difference("Sensor.count", -1) do
      delete sensor_url(@sensor), as: :json
    end

    assert_response :no_content
  end
end
