module Api
  class CulturasController < ApplicationController
    before_action :authenticate_user!
    before_action :set_cultura, only: %i[show update destroy]

    def index
      culturas = Cultura.all.order(:nome)
      render json: { data: culturas.map(&:as_json_public) }, status: :ok
    end

    def show
      render json: {
        data: @cultura.as_json_public.merge(
          historico_cotacoes: @cultura.preco_mercados.order(data_cotacao: :desc).map(&:as_json_public)
        )
      }, status: :ok
    end

    def create
      cultura = Cultura.new(cultura_params)
      if cultura.save
        render json: { data: cultura.as_json_public, message: "Cultura cadastrada" }, status: :created
      else
        render_validation_errors(cultura)
      end
    end

    def update
      if @cultura.update(cultura_params)
        render json: { data: @cultura.as_json_public, message: "Cultura atualizada" }, status: :ok
      else
        render_validation_errors(@cultura)
      end
    end

    def destroy
      @cultura.destroy!
      render json: { data: {}, message: "Cultura removida" }, status: :ok
    end

    private

    def set_cultura
      @cultura = Cultura.find(params[:id])
    end

    def cultura_params
      source = params[:cultura].present? ? params.require(:cultura) : params
      source.permit(
        :nome,
        :ciclo_medio_dias,
        :temperatura_min,
        :temperatura_max,
        :umidade_min,
        :umidade_max
      )
    end
  end
end
