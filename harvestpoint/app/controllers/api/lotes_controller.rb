module Api
  class LotesController < ApplicationController
    before_action :authenticate_user!
    before_action :set_lote, only: %i[show update destroy]

    def index
      lotes = user_lotes_scope.includes(:propriedade, :historico_cultivos, :culturas, :sensores).order(:nome)
      render json: { data: lotes.map(&:as_json_public) }, status: :ok
    end

    def show
      ultimas_leituras = @lote.sensores.joins(:leitura_sensores)
                              .order("leitura_sensores.data_hora DESC")
                              .limit(50)
                              .map(&:leitura_sensores)
                              .flatten
                              .sort_by(&:data_hora)
                              .reverse
                              .take(20)

      render json: {
        data: @lote.as_json_public.merge(
          sensores: @lote.sensores.map(&:as_json_public),
          alertas_recentes: @lote.sensores.joins(:alertas).order("alertas.data_hora DESC").limit(10).map(&:alertas).flatten.map(&:as_json_public),
          leituras: ultimas_leituras.map(&:as_json_public),
          recomendacoes: @lote.recomendacao_colheitas.order(data_atualizacao: :desc).map(&:as_json_public)
        )
      }, status: :ok
    end

    def create
      propriedade = resolve_propriedade
      unless propriedade
        return render json: {
          error: "propriedade_missing",
          message: "Nenhuma propriedade encontrada ou informada para o lote"
        }, status: :unprocessable_content
      end

      nome = params[:nome].presence || params[:codigo].presence || params.dig(:lote, :nome) || params.dig(:lote, :codigo)
      area = params[:area].presence || params[:area_ha].presence || params.dig(:lote, :area) || params.dig(:lote, :area_ha)

      if area.is_a?(String)
        area = area.tr(",", ".").to_f
      end

      lote = propriedade.lotes.new(
        nome: nome,
        area: area
      )

      if lote.save
        # Vincula Cultura via HistoricoCultivo se informada
        vincular_cultura(lote)

        # Vincula Sensor se informado
        vincular_sensor(lote)

        render json: { data: lote.as_json_public }, status: :created
      else
        render_validation_errors(lote)
      end
    end

    def update
      p_params = lote_update_params

      if @lote.update(p_params)
        @lote.status = params[:status] || params.dig(:lote, :status) if params[:status].present? || params.dig(:lote, :status).present?
        vincular_cultura(@lote) if params[:cultura].present? || params[:data_plantio].present?
        vincular_sensor(@lote) if params[:sensor_vinculado].present? || params[:sensor_codigo].present?

        render json: { data: @lote.as_json_public }, status: :ok
      else
        render_validation_errors(@lote)
      end
    end

    def destroy
      @lote.destroy!
      render json: { data: {}, message: "Lote excluído" }, status: :ok
    end

    private

    def user_lotes_scope
      current_user.lotes_visiveis
    end

    def set_lote
      @lote = user_lotes_scope.find(params[:id])
    end

    def resolve_propriedade
      source = params[:lote].present? ? params[:lote] : params

      if source[:propriedade_id].present?
        current_user.propriedades.find_by(id: source[:propriedade_id]) || Propriedade.find_by(id: source[:propriedade_id])
      elsif source[:propriedade].present?
        nome_prop = source[:propriedade].to_s.strip
        current_user.propriedades.find_or_create_by!(nome: nome_prop) do |p|
          p.municipio = "Petrolina - PE"
          p.latitude = -9.3891
          p.longitude = -40.5027
          p.area_total = 100.00
        end
      else
        current_user.propriedades.first || current_user.propriedades.create!(
          nome: "Propriedade Principal",
          municipio: "Petrolina - PE",
          latitude: -9.3891,
          longitude: -40.5027,
          area_total: 100.00
        )
      end
    end

    def lote_update_params
      source = params[:lote].present? ? params.require(:lote) : params
      res = {}
      res[:nome] = source[:nome] || source[:codigo] if source[:nome].present? || source[:codigo].present?
      if source[:area].present? || source[:area_ha].present?
        raw_area = source[:area] || source[:area_ha]
        res[:area] = raw_area.is_a?(String) ? raw_area.tr(",", ".").to_f : raw_area.to_f
      end
      res[:propriedade_id] = source[:propriedade_id] if source[:propriedade_id].present?
      res
    end

    def vincular_cultura(lote)
      source = params[:lote].present? ? params[:lote] : params
      nome_cultura = (source[:cultura].presence || source[:variedade]).to_s.strip
      data_plantio = source[:data_plantio].presence || Date.current
      status_cult = source[:status].presence || "ATIVO"

      return if nome_cultura.blank?

      cultura = Cultura.where("LOWER(nome) = ?", nome_cultura.downcase).first ||
                Cultura.create!(
                  nome: nome_cultura,
                  ciclo_medio_dias: 120,
                  temperatura_min: 22.0,
                  temperatura_max: 35.0,
                  umidade_min: 40.0,
                  umidade_max: 70.0
                )

      hist = lote.historico_ativo || lote.historico_cultivos.new
      hist.cultura = cultura
      hist.data_plantio = data_plantio
      hist.status = status_cult.upcase == "FINALIZADO" ? "FINALIZADO" : "ATIVO"
      hist.save!
    end

    def vincular_sensor(lote)
      source = params[:lote].present? ? params[:lote] : params
      codigo_sensor = (source[:sensor_vinculado].presence || source[:sensor_codigo]).to_s.strip
      return if codigo_sensor.blank?

      sensor = Sensor.find_by(codigo: codigo_sensor)
      if sensor
        sensor.update!(lote_id: lote.id)
      else
        lote.sensores.create!(
          codigo: codigo_sensor,
          status: "ATIVO"
        )
      end
    end
  end
end
