# frozen_string_literal: true

module Authenticable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate_usuario!
  end

  private

  def authenticate_usuario!
    header = request.headers["Authorization"]
    token = header.to_s.split(" ").last
    decoded = JsonWebToken.decode(token)
    @current_usuario = Usuario.find(decoded[:usuario_id]) if decoded

    render json: { errors: [ "Não autenticado" ] }, status: :unauthorized unless @current_usuario
  rescue JWT::DecodeError, JWT::ExpiredSignature, ActiveRecord::RecordNotFound
    render json: { errors: [ "Não autenticado" ] }, status: :unauthorized
  end

  def current_usuario
    @current_usuario
  end

  def current_produtor
    current_usuario&.produtor
  end

  def require_produtor!
    return if current_produtor

    render json: { errors: [ "Usuário sem produtor vinculado" ] }, status: :forbidden
  end
end
