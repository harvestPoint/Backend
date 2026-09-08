class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :registro_nao_encontrado

  private

  def registro_nao_encontrado
    render json: { errors: [ "Registro não encontrado" ] }, status: :not_found
  end
end
