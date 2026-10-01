module Api
  class AlertasController < ApplicationController
    before_action :authenticate_user!
    before_action :set_alerta, only: %i[show update resolver destroy]

    def index
      alertas = Alerta.includes(sensor: { lote: :propriedade })
                      .where(sensor_id: current_user.sensores_visiveis.select(:id))
                      .order(data_hora: :desc)

      if params[:resolvido].present?
        resolvido_bool = ActiveModel::Type::Boolean.new.cast(params[:resolvido])
        alertas = alertas.where(resolvido: resolvido_bool)
      end

      if params[:lote_id].present?
        alertas = alertas.joins(:sensor).where(sensores: { lote_id: params[:lote_id] })
      end

      if params[:sensor_id].present?
        alertas = alertas.where(sensor_id: params[:sensor_id])
      end

      render json: {
        total: alertas.count,
        pendentes: alertas.where(resolvido: false).count,
        data: alertas.limit(100).map(&:as_json_public)
      }, status: :ok
    end

    def show
      render json: { data: @alerta.as_json_public }, status: :ok
    end

    def update
      if params[:resolvido].present?
        @alerta.resolvido = ActiveModel::Type::Boolean.new.cast(params[:resolvido])
      end

      if @alerta.save
        render json: { data: @alerta.as_json_public, message: "Alerta atualizado" }, status: :ok
      else
        render_validation_errors(@alerta)
      end
    end

    def resolver
      @alerta.resolver!
      render json: { data: @alerta.as_json_public, message: "Alerta marcado como resolvido" }, status: :ok
    end

    def destroy
      @alerta.destroy!
      render json: { data: {}, message: "Alerta excluído" }, status: :ok
    end

    private

    def set_alerta
      @alerta = Alerta.where(sensor_id: current_user.sensores_visiveis.select(:id)).find(params[:id])
    end
  end
end
