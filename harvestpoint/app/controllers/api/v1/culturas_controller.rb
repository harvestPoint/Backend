module Api
  module V1
    class CulturasController < BaseController
      before_action :set_cultura, only: %i[show update destroy]

      def index
        render json: Cultura.order(:nome)
      end

      def show
        render json: @cultura
      end

      def create
        cultura = Cultura.new(cultura_params)

        if cultura.save
          render json: cultura, status: :created
        else
          render json: { errors: cultura.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @cultura.update(cultura_params)
          render json: @cultura
        else
          render json: { errors: @cultura.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @cultura.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotDestroyed
        render json: { errors: @cultura.errors.full_messages }, status: :unprocessable_content
      end

      private

      def set_cultura
        @cultura = Cultura.find(params[:id])
      end

      def cultura_params
        params.require(:cultura).permit(
          :nome, :variedade, :temperatura_min, :temperatura_max,
          :umidade_min, :umidade_max, :ciclo_medio_dias, :descricao
        )
      end
    end
  end
end
