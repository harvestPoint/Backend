module Api
  class PropriedadesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_propriedade, only: %i[show update destroy]

    def index
      props = current_user.propriedades_visiveis
      render json: { data: props.order(:nome).map(&:as_json_public) }, status: :ok
    end

    def show
      render json: {
        data: @propriedade.as_json_public.merge(
          lotes: @propriedade.lotes.map(&:as_json_public),
          clima_previsoes: @propriedade.clima_regioes.order(:data_previsao).map(&:as_json_public)
        )
      }, status: :ok
    end

    def create
      owner = if current_user.tecnico? && params[:usuario_id].present?
                Usuario.find(params[:usuario_id])
              else
                current_user
              end
      prop = owner.propriedades.new(propriedade_params)
      if prop.save
        render json: { data: prop.as_json_public, message: "Propriedade cadastrada" }, status: :created
      else
        render_validation_errors(prop)
      end
    end

    def update
      if @propriedade.update(propriedade_params)
        render json: { data: @propriedade.as_json_public, message: "Propriedade atualizada" }, status: :ok
      else
        render_validation_errors(@propriedade)
      end
    end

    def destroy
      @propriedade.destroy!
      render json: { data: {}, message: "Propriedade removida" }, status: :ok
    end

    private

    def set_propriedade
      scope = current_user.propriedades_visiveis
      @propriedade = scope.find(params[:id])
    end

    def propriedade_params
      source = params[:propriedade].present? ? params.require(:propriedade) : params
      source.permit(:nome, :municipio, :latitude, :longitude, :area_total)
    end
  end
end
