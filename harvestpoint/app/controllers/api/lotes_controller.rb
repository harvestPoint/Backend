module Api
  class LotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_lote, only: %i[show update destroy]

    def index
      lotes = current_user.lotes.order(:codigo)
      render json: { data: lotes.map(&:as_json_public) }, status: :ok
    end

    def show
      render json: { data: @lote.as_json_public }, status: :ok
    end

    def create
      lote = current_user.lotes.new(lote_params)

      if lote.save
        render json: { data: lote.as_json_public }, status: :created
      else
        render_validation_errors(lote)
      end
    end

    def update
      if @lote.update(lote_params)
        render json: { data: @lote.as_json_public }, status: :ok
      else
        render_validation_errors(@lote)
      end
    end

    def destroy
      @lote.destroy!
      render json: { data: {}, message: "Lote excluído" }, status: :ok
    end

    private

    def set_lote
      @lote = current_user.lotes.find(params[:id])
    end

    def lote_params
      source = params[:lote].present? ? params.require(:lote) : params
      permitted = source.permit(
        :codigo,
        :propriedade,
        :cultura,
        :variedade,
        :area_ha,
        :data_plantio,
        :sensor_vinculado,
        :status
      ).to_h

      if permitted["propriedade"].blank? && current_user&.propriedade.present?
        permitted["propriedade"] = current_user.propriedade
      end

      permitted
    end
  end
end
