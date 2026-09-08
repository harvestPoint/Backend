module Api
  module V1
    class ProdutoresController < BaseController
      before_action :require_produtor!, only: %i[index show update destroy]
      before_action :set_produtor, only: %i[show update destroy]

      def index
        render json: [ current_produtor ]
      end

      def show
        render json: @produtor
      end

      def create
        if current_produtor
          return render json: { errors: [ "Usuário já possui produtor vinculado" ] },
                        status: :unprocessable_content
        end

        produtor = Produtor.new(produtor_params)

        if produtor.save
          current_usuario.update!(produtor: produtor)
          render json: produtor, status: :created
        else
          render json: { errors: produtor.errors.full_messages }, status: :unprocessable_content
        end
      end

      def update
        if @produtor.update(produtor_params)
          render json: @produtor
        else
          render json: { errors: @produtor.errors.full_messages }, status: :unprocessable_content
        end
      end

      def destroy
        @produtor.destroy!
        head :no_content
      rescue ActiveRecord::RecordNotDestroyed
        render json: { errors: @produtor.errors.full_messages }, status: :unprocessable_content
      end

      private

      def set_produtor
        unless current_produtor.id == params[:id].to_i
          raise ActiveRecord::RecordNotFound
        end

        @produtor = current_produtor
      end

      def produtor_params
        params.require(:produtor).permit(
          :nome_razao_social, :cpf_cnpj, :telefone, :email, :cidade, :estado, :responsavel
        )
      end
    end
  end
end
