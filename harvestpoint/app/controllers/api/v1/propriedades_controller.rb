module Api
  module V1
    class PropriedadesController < BaseController
      before_action :require_produtor!
      before_action :set_propriedade, only: %i[show update destroy]

      def index
        render json: current_produtor.propriedades.order(:id)
      end

      def show
        render json: @propriedade
      end

      def create
        propriedade = current_produtor.propriedades.new(propriedade_params)

        if propriedade.save
          render json: propriedade, status: :created
        else
          render json: { errors: propriedade.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @propriedade.update(propriedade_params)
          render json: @propriedade
        else
          render json: { errors: @propriedade.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @propriedade.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotDestroyed
        render json: { errors: @propriedade.errors.full_messages }, status: :unprocessable_content
      end

      private

      def set_propriedade
        @propriedade = current_produtor.propriedades.find(params[:id])
      end

      def propriedade_params
        params.require(:propriedade).permit(
          :nome, :municipio, :estado, :latitude, :longitude, :area_total, :status
        )
      end
    end
  end
end
