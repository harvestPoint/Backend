module Api
  class UsuariosController < ApplicationController
    before_action :authenticate_user!
    before_action :set_usuario, only: %i[show update]

    def index
      usuarios = Usuario.order(:nome)
      if params[:tipo].present?
        usuarios = usuarios.where(tipo_usuario: params[:tipo].to_s.upcase)
      end

      render json: {
        total: usuarios.count,
        data: usuarios.map(&:as_json_public)
      }, status: :ok
    end

    def show
      render json: { data: @usuario.as_json_public }, status: :ok
    end

    def update
      # Permite ao usuário atualizar seus dados ou ao técnico gerenciar
      permitted = params.permit(:nome, :email, :telefone, :cpf_cnpj, :tipo_usuario, :senha, :password)

      @usuario.nome = permitted[:nome] if permitted[:nome].present?
      @usuario.email = permitted[:email] if permitted[:email].present?
      @usuario.telefone = permitted[:telefone] if permitted[:telefone].present?
      @usuario.cpf_cnpj = permitted[:cpf_cnpj] if permitted[:cpf_cnpj].present?
      @usuario.tipo_usuario = permitted[:tipo_usuario].to_s.upcase if permitted[:tipo_usuario].present?
      @usuario.password = permitted[:senha] || permitted[:password] if (permitted[:senha] || permitted[:password]).present?

      if @usuario.save
        render json: { data: @usuario.as_json_public, message: "Perfil atualizado com sucesso" }, status: :ok
      else
        render_validation_errors(@usuario)
      end
    end

    private

    def set_usuario
      @usuario = params[:id] == "me" ? current_user : Usuario.find(params[:id])
    end
  end
end
