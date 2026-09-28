class SensorsController < ApplicationController
  before_action :set_sensor, only: %i[ show update destroy ]

  # GET /sensors
  def index
    @sensors = Sensor.all

    render json: @sensors
  end

  # GET /sensors/1
  def show
    render json: @sensor
  end

  # POST /sensors
  def create
    @sensor = Sensor.new(sensor_params)

    if @sensor.save
      render json: @sensor, status: :created, location: @sensor
    else
      render json: @sensor.errors, status: :unprocessable_content
    end
  end

  # PATCH/PUT /sensors/1
  def update
    if @sensor.update(sensor_params)
      render json: @sensor
    else
      render json: @sensor.errors, status: :unprocessable_content
    end
  end

  # DELETE /sensors/1
  def destroy
    @sensor.destroy!
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sensor
      @sensor = Sensor.find(params.expect(:id))
    end

    # Only allow a list of trusted parameters through.
    def sensor_params
      params.expect(sensor: [ :lote_id, :tipo, :unidade_medida, :status, :data_instalacao ])
    end
end
