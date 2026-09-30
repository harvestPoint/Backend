module Api
  # Catálogo de referência (faixas ideais por cultura/variedade). É global —
  # não pertence a um usuário — mas só fica visível para quem está autenticado.
  class CulturasController < ApplicationController
    before_action :authenticate_user!
    before_action :set_cultura, only: %i[show update destroy]

    def index
      culturas = Cultura.order(:nome, :variedade)
      render json: { data: culturas.map(&:as_json_public) }, status: :ok
    end

    def show
      render json: { data: @cultura.as_json_public }, status: :ok
    end

    def create
      cultura = Cultura.new(cultura_params)

      if cultura.save
        render json: { data: cultura.as_json_public }, status: :created
      else
        render_validation_errors(cultura)
      end
    end

    def update
      if @cultura.update(cultura_params)
        render json: { data: @cultura.as_json_public }, status: :ok
      else
        render_validation_errors(@cultura)
      end
    end

    def destroy
      @cultura.destroy!
      render json: { data: {}, message: "Cultura excluída" }, status: :ok
    end

    private

    def set_cultura
      @cultura = Cultura.find(params[:id])
    end

    def cultura_params
      source = params[:cultura].present? ? params.require(:cultura) : params
      source.permit(
        :nome, :variedade, :ciclo_dias,
        :temperatura_min, :temperatura_max,
        :umidade_ar_min, :umidade_ar_max,
        :umidade_solo_min, :umidade_solo_max
      )
    end
  end
end
