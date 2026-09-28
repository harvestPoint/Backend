module Api
  module Auth
    class RegistrationsController < ApplicationController
      def create
        user = User.new(registration_params)

        if user.save
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
        permitted = source.permit(:nome, :email, :senha, :password, :role, :propriedade)
        {
          nome: permitted[:nome],
          email: permitted[:email],
          password: permitted[:senha].presence || permitted[:password],
          role: permitted[:role].presence || "proprietario",
          propriedade: permitted[:propriedade]
        }
      end

      def email_taken?(user)
        user.errors.details[:email]&.any? { |detail| detail[:error] == :taken }
      end
    end
  end
end
