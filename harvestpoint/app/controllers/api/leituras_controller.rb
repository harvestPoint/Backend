module Api
  class LeiturasController < ApplicationController
    # Um dispositivo de campo não tem sessão de usuário: ele se identifica pelo
    # token do próprio sensor (cabeçalho X-Sensor-Token), só para enviar leituras.
    before_action :authenticate_user!, unless: :sensor_token_presente?
    before_action :set_sensor_via_token, if: :sensor_token_presente?
    before_action :set_leitura, only: :show

    def index
      leituras = current_user.leituras
        .includes(:sensor, :lote)
        .then { |escopo| params[:lote_id].present? ? escopo.where(lote_id: params[:lote_id]) : escopo }
        .then { |escopo| params[:sensor_id].present? ? escopo.where(sensor_id: params[:sensor_id]) : escopo }
        .order(medido_em: :desc)
        .limit(limite)

      render json: { data: leituras.map(&:as_json_public) }, status: :ok
    end

    def show
      render json: { data: @leitura.as_json_public }, status: :ok
    end

    def create
      leitura = sensor_do_request.leituras.new(leitura_params)

      if leitura.save
        render json: { data: leitura.as_json_public }, status: :created
      else
        render_validation_errors(leitura)
      end
    end

    private

    def sensor_token_presente?
      request.headers["X-Sensor-Token"].present?
    end

    def set_sensor_via_token
      @sensor_autenticado = Sensor.find_by(token: request.headers["X-Sensor-Token"].to_s.strip)
      return if @sensor_autenticado

      render json: { error: "sensor_invalido", message: "Token de sensor inválido" }, status: :unauthorized
    end

    def sensor_do_request
      @sensor_autenticado || current_user.sensores.find(params[:sensor_id])
    end

    def set_leitura
      @leitura = current_user.leituras.find(params[:id])
    end

    def leitura_params
      source = params[:leitura].present? ? params.require(:leitura) : params
      source.permit(:medido_em, :temperatura, :umidade_ar, :umidade_solo, :precipitacao, :origem)
    end

    def limite
      valor = params[:limit].to_i
      valor.positive? ? [ valor, 500 ].min : 100
    end
  end
end
