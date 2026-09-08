module Api
  module V1
    class AuthController < ApplicationController
      def register
        ApplicationRecord.transaction do
          produtor = Produtor.create!(produtor_params)
          usuario = Usuario.new(usuario_params)
          usuario.produtor = produtor
          usuario.tipo_usuario = Usuario::TIPO_PRODUTOR
          usuario.save!
          render json: payload_autenticado(usuario), status: :created
        end
      rescue ActiveRecord::RecordInvalid => e
        render json: { errors: e.record.errors.full_messages }, status: :unprocessable_content
      end

      def login
        usuario = Usuario.find_by(email: params[:email].to_s.downcase)

        if usuario&.authenticate(params[:password]) && usuario.ativo?
          render json: payload_autenticado(usuario), status: :ok
        else
          render json: { errors: [ "Credenciais inválidas" ] }, status: :unauthorized
        end
      end

      private

      def payload_autenticado(usuario)
        {
          token: JsonWebToken.encode(usuario_id: usuario.id),
          usuario: usuario,
          produtor: usuario.produtor
        }
      end

      def usuario_params
        permitted = params.require(:usuario).permit(
          :nome, :cpf, :email, :telefone, :password, :password_confirmation
        )
        permitted[:email] = permitted[:email].to_s.downcase.presence
        permitted
      end

      def produtor_params
        params.require(:produtor).permit(
          :nome_razao_social, :cpf_cnpj, :telefone, :email, :cidade, :estado, :responsavel
        )
      end
    end
  end
end
