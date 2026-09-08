module Api
  module V1
    class LotesController < BaseController
      before_action :require_produtor!
      before_action :set_lote, only: %i[show update destroy]

      def index
        render json: lotes_do_produtor.order(:id)
      end

      def show
        render json: @lote
      end

      def create
        lote = Lote.new(lote_params)

        unless propriedade_do_produtor?(lote.propriedade_id)
          return render json: { errors: [ "Propriedade não pertence ao produtor autenticado" ] },
                        status: :unprocessable_content
        end

        if lote.save
          render json: lote, status: :created
        else
          render json: { errors: lote.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        nova_propriedade_id = lote_params[:propriedade_id]
        if nova_propriedade_id.present? && !propriedade_do_produtor?(nova_propriedade_id)
          return render json: { errors: [ "Propriedade não pertence ao produtor autenticado" ] },
                        status: :unprocessable_content
        end

        if @lote.update(lote_params)
          render json: @lote
        else
          render json: { errors: @lote.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @lote.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotDestroyed
        render json: { errors: @lote.errors.full_messages }, status: :unprocessable_content
      end

      private

      def lotes_do_produtor
        Lote.joins(:propriedade).where(propriedades: { produtor_id: current_produtor.id })
      end

      def set_lote
        @lote = lotes_do_produtor.find(params[:id])
      end

      def propriedade_do_produtor?(propriedade_id)
        current_produtor.propriedades.exists?(id: propriedade_id)
      end

      def lote_params
        params.require(:lote).permit(
          :propriedade_id, :cultura_id, :nome, :area,
          :data_plantio, :previsao_colheita, :situacao
        )
      end
    end
  end
end
