module Api
  class ClimaController < ApplicationController
    before_action :authenticate_user!

    def index
      prop_id = params[:propriedade_id]
      climas = ClimaRegiao.includes(:propriedade)
                          .where(propriedade_id: current_user.propriedades_visiveis.select(:id))
                          .order(:data_previsao)
      climas = climas.where(propriedade_id: prop_id) if prop_id.present?

      render json: {
        data: climas.map(&:as_json_public)
      }, status: :ok
    end

    def create
      prop = current_user.propriedades_visiveis.find(params[:propriedade_id])
      clima = prop.clima_regioes.new(
        data_previsao: params[:data_previsao].presence || Date.current,
        temperatura_min: params[:temperatura_min],
        temperatura_max: params[:temperatura_max],
        chance_chuva_percentual: params[:chance_chuva_percentual],
        precipitacao_mm: params[:precipitacao_mm]
      )

      if clima.save
        render json: { data: clima.as_json_public, message: "Previsão registrada" }, status: :created
      else
        render_validation_errors(clima)
      end
    end
  end
end
