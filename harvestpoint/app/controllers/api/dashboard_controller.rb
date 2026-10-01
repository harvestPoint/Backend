module Api
  class DashboardController < ApplicationController
    before_action :authenticate_user!

    def index
      prop_id = params[:propriedade_id]
      lotes_scope = current_user.lotes_visiveis
      if prop_id.present?
        lotes_scope = lotes_scope.where(propriedade_id: prop_id)
      end

      sensores_scope = Sensor.where(lote_id: lotes_scope.select(:id))
      leituras_scope = LeituraSensor.where(sensor_id: sensores_scope.select(:id))
      alertas_scope = Alerta.where(sensor_id: sensores_scope.select(:id))

      ultima_leitura = leituras_scope.order(data_hora: :desc).first
      alertas_pendentes = alertas_scope.where(resolvido: false).order(data_hora: :desc).limit(5)
      recs_pendentes = RecomendacaoColheita.where(lote_id: lotes_scope.select(:id), status: "PENDENTE").order(data_atualizacao: :desc).limit(3)
      clima = ClimaRegiao.where(propriedade_id: lotes_scope.select(:propriedade_id)).order(:data_previsao).limit(8)

      render json: {
        resumo: {
          total_propriedades: current_user.propriedades_visiveis.count,
          total_lotes: lotes_scope.count,
          area_monitorada_ha: lotes_scope.sum(:area).to_f,
          total_sensores: sensores_scope.count,
          sensores_ativos: sensores_scope.where(status: "ATIVO").count,
          alertas_pendentes_count: alertas_scope.where(resolvido: false).count,
          total_leituras: leituras_scope.count
        },
        ultima_leitura: ultima_leitura&.as_json_public,
        alertas_recentes: alertas_pendentes.map(&:as_json_public),
        lotes: lotes_scope.map(&:as_json_public),
        recomendacoes: recs_pendentes.map(&:as_json_public),
        previsao_clima: clima.map(&:as_json_public)
      }, status: :ok
    end
  end
end
