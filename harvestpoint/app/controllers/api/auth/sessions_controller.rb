module Api
  module Auth
    class SessionsController < ApplicationController
      before_action :authenticate_user!, only: %i[show destroy]

      def create
        source = params[:user].present? ? params[:user] : params
        email = source[:email].to_s.strip.downcase
        password = source[:senha].presence || source[:password]

        if email.blank? || password.blank?
          return render json: {
            error: "invalid_credentials",
            message: "Email e senha são obrigatórios"
          }, status: :unauthorized
        end

        user = User.find_by(email: email)

        unless user
          return render json: {
            error: "user_not_found",
            message: "Usuário inexistente"
          }, status: :unauthorized
        end

        unless user.authenticate(password.to_s)
          return render json: {
            error: "invalid_credentials",
            message: "Credenciais inválidas"
          }, status: :unauthorized
        end

        token = user.issue_api_token!
        render json: {
          data: {
            user: user.as_json_public,
            token: token
          }
        }, status: :ok
      end

      def show
        render json: { data: { user: current_user.as_json_public } }, status: :ok
      end

      def destroy
        current_user.clear_api_token!
        render json: { data: {}, message: "Logout realizado" }, status: :ok
      end
    end
  end
end
