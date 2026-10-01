module Api
  class SensoresController < ApplicationController
    before_action :authenticate_user!, except: %i[leitura]
    before_action :set_sensor, only: %i[show update destroy]

    def index
      sensores = current_user.sensores_visiveis.includes(:lote, :alertas).order(:codigo)
      if params[:lote_id].present?
        sensores = sensores.where(lote_id: params[:lote_id])
      end
      if params[:status].present?
        sensores = sensores.where(status: params[:status].upcase)
      end

      render json: { data: sensores.map(&:as_json_public) }, status: :ok
    end

    def show
      ultimas = @sensor.leitura_sensores.order(data_hora: :desc).limit(30)
      render json: {
        data: @sensor.as_json_public.merge(
          leituras_recentes: ultimas.map(&:as_json_public),
          alertas: @sensor.alertas.order(data_hora: :desc).map(&:as_json_public)
        )
      }, status: :ok
    end

    def create
      sensor = Sensor.new(sensor_params)
      if sensor.save
        render json: { data: sensor.as_json_public, message: "Sensor cadastrado com sucesso" }, status: :created
      else
        render_validation_errors(sensor)
      end
    end

    def update
      if @sensor.update(sensor_params)
        render json: { data: @sensor.as_json_public, message: "Sensor atualizado com sucesso" }, status: :ok
      else
        render_validation_errors(@sensor)
      end
    end

    def destroy
      @sensor.destroy!
      render json: { data: {}, message: "Sensor removido com sucesso" }, status: :ok
    end

    # Endpoint para recepção de telemetria do ESP-32
    # POST /api/sensores/leitura
    # POST /api/sensores/:codigo/leituras
    def leitura
      codigo = params[:codigo].presence || params[:mac].presence || params[:sensor_codigo].presence
      sensor_id = params[:sensor_id].presence || params[:id].presence

      sensor = if codigo.present?
                 Sensor.find_by(codigo: codigo)
               elsif sensor_id.present?
                 Sensor.find_by(id: sensor_id)
               end

      # Se o sensor ainda não existir, auto-cadastra no primeiro lote para facilitar testes no campo
      unless sensor
        lote = Lote.first || Propriedade.first&.lotes&.create!(nome: "Lote Geral", area: 50.0)
        unless lote
          prop = Propriedade.create!(
            usuario: Usuario.first,
            nome: "Propriedade Padrão",
            municipio: "Petrolina - PE",
            latitude: -9.3891,
            longitude: -40.5027,
            area_total: 100.00
          )
          lote = prop.lotes.create!(nome: "Lote Geral", area: 50.0)
        end

        sensor = Sensor.create!(
          codigo: codigo.presence || "ESP32-#{SecureRandom.hex(4).upcase}",
          lote: lote,
          status: "ATIVO"
        )
      end

      # Parser de temperatura e umidade com suporte a vírgula ou ponto
      raw_temp = params[:temperatura] || params[:temp]
      raw_umid = params[:umidade] || params[:umid] || params[:humidity]

      if raw_temp.blank? || raw_umid.blank?
        return render json: {
          error: "missing_telemetry",
          message: "Parâmetros 'temperatura' e 'umidade' são obrigatórios"
        }, status: :bad_request
      end

      temp = raw_temp.to_s.tr(",", ".").to_f
      umid = raw_umid.to_s.tr(",", ".").to_f
      data_hora = params[:data_hora].present? ? Time.zone.parse(params[:data_hora].to_s) : Time.current

      leitura = sensor.leitura_sensores.new(
        temperatura: temp,
        umidade: umid,
        data_hora: data_hora
      )

      if leitura.save
        # Coleta alertas gerados por esta leitura
        novos_alertas = sensor.alertas.where(data_hora: data_hora).map(&:as_json_public)

        render json: {
          status: "success",
          message: "Leitura do sensor ESP-32 registrada com sucesso",
          data: {
            leitura: leitura.as_json_public,
            alertas_gerados: novos_alertas
          }
        }, status: :created
      else
        render_validation_errors(leitura)
      end
    end

    private

    def set_sensor
      @sensor = current_user.sensores_visiveis.find(params[:id])
    end

    def sensor_params
      source = params[:sensor].present? ? params.require(:sensor) : params
      source.permit(:codigo, :lote_id, :status)
    end
  end
end
