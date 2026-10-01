module Authenticatable
  extend ActiveSupport::Concern

  included do
    attr_reader :current_user
  end

  private

  def authenticate_user!
    @current_user = user_from_token
    return if @current_user

    render json: {
      error: "unauthenticated",
      message: "Requisição sem autenticação"
    }, status: :unauthorized
  end

  def user_from_token
    header = request.headers["Authorization"].to_s.strip
    return if header.blank?

    token = header.sub(/\ABearer\s+/i, "").strip
    Usuario.find_by_api_token(token)
  end
end
