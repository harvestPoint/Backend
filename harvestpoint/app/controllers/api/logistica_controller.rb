module Api
  class LogisticaController < ApplicationController
    before_action :authenticate_user!

    def index
      dados = ComexStatService.dados_logistica
      render json: { data: dados }, status: :ok
    end
  end
end
