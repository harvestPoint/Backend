module Api
  module Auth
    class RegistrationsController < ApplicationController
      def create
        user = Usuario.new(registration_params)

        if user.save
          if params[:propriedade].present? || params.dig(:user, :propriedade).present?
            nome_prop = (params[:propriedade].presence || params.dig(:user, :propriedade)).to_s.strip
            if nome_prop.present?
              user.propriedades.create(
                nome: nome_prop,
                municipio: "Petrolina - PE",
                latitude: -9.3891,
                longitude: -40.5027,
                area_total: 100.00
              )
            end
          end

          token = user.issue_api_token!
          render json: {
            data: {
              user: user.as_json_public,
              token: token
            },
            message: "Cadastro realizado"
          }, status: :created
        elsif email_taken?(user)
          render json: {
            error: "user_already_exists",
            message: "Usuário já cadastrado"
          }, status: :conflict
        else
          render_validation_errors(user)
        end
      end

      private

      def registration_params
        source = params[:user].present? ? params.require(:user) : params
        permitted = source.permit(:nome, :email, :senha, :password, :role, :tipo_usuario, :cpf_cnpj, :telefone, :propriedade)
        tipo = permitted[:tipo_usuario].presence || (permitted[:role].to_s.downcase == "tecnico" ? "TECNICO" : "PRODUTOR")

        {
          nome: permitted[:nome],
          email: permitted[:email],
          password: permitted[:senha].presence || permitted[:password],
          tipo_usuario: tipo,
          cpf_cnpj: permitted[:cpf_cnpj],
          telefone: permitted[:telefone]
        }
      end

      def email_taken?(user)
        user.errors.details[:email]&.any? { |detail| detail[:error] == :taken }
      end
    end
  end
end
