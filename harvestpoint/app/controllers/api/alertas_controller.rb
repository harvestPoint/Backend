module Api
  class AlertasController < ApplicationController
    before_action :authenticate_user!
    before_action :set_alerta, only: %i[show update]

    def index
      alertas = current_user.alertas
        .includes(:lote, :sensor)
        .then { |escopo| params[:status].present? ? escopo.where(status: params[:status]) : escopo.ativos }
        .order(Arel.sql("CASE severidade WHEN 'critico' THEN 0 WHEN 'atencao' THEN 1 ELSE 2 END"), created_at: :desc)

      render json: { data: alertas.map(&:as_json_public) }, status: :ok
    end

    def show
      render json: { data: @alerta.as_json_public }, status: :ok
    end

    # Uso principal: marcar como "em_analise" ou "resolvido" manualmente.
    def update
      if @alerta.update(status_params)
        render json: { data: @alerta.as_json_public }, status: :ok
      else
        render_validation_errors(@alerta)
      end
    end

    private

    def set_alerta
      @alerta = current_user.alertas.find(params[:id])
    end

    def status_params
      source = params[:alerta].present? ? params.require(:alerta) : params
      source.permit(:status)
    end
  end
end
