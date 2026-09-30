module Api
  class SensoresController < ApplicationController
    before_action :authenticate_user!
    before_action :set_sensor, only: %i[show update destroy]

    def index
      sensores = current_user.sensores.includes(:lote).order(:codigo)
      render json: { data: sensores.map(&:as_json_public) }, status: :ok
    end

    def show
      render json: { data: @sensor.as_json_public }, status: :ok
    end

    def create
      sensor = current_user.sensores.new(sensor_params)

      if sensor.save
        # O token só é devolvido na criação: é o que o dispositivo usa para enviar leituras.
        render json: { data: sensor.as_json_public.merge(token: sensor.token) }, status: :created
      else
        render_validation_errors(sensor)
      end
    end

    def update
      if @sensor.update(sensor_params)
        render json: { data: @sensor.as_json_public }, status: :ok
      else
        render_validation_errors(@sensor)
      end
    end

    def destroy
      @sensor.destroy!
      render json: { data: {}, message: "Sensor excluído" }, status: :ok
    end

    private

    def set_sensor
      @sensor = current_user.sensores.find(params[:id])
    end

    def sensor_params
      source = params[:sensor].present? ? params.require(:sensor) : params
      permitted = source.permit(:codigo, :lote_id, :instalado_em, grandezas: [])
      permitted[:grandezas] ||= source[:grandezas] if source[:grandezas].is_a?(String)
      permitted
    end
  end
end
