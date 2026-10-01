module Api
  class LeiturasController < ApplicationController
    before_action :authenticate_user!, except: %i[create]

    def index
      leituras = LeituraSensor.includes(sensor: { lote: %i[propriedade culturas] })
                             .where(sensor_id: current_user.sensores_visiveis.select(:id))
                             .order(data_hora: :desc)

      if params[:sensor_id].present?
        leituras = leituras.where(sensor_id: params[:sensor_id])
      end

      if params[:lote_id].present?
        leituras = leituras.joins(:sensor).where(sensores: { lote_id: params[:lote_id] })
      end

      if params[:format] == "csv" || request.format.csv?
        leituras = leituras.limit(1000)
        lines = [ "ID;Sensor (MAC);Lote;Propriedade;Temperatura (°C);Umidade (%);Data/Hora" ]
        leituras.each do |l|
          lines << "#{l.id};#{l.sensor&.codigo};#{l.sensor&.lote&.nome};#{l.sensor&.lote&.propriedade&.nome};#{l.temperatura.to_f};#{l.umidade.to_f};#{l.data_hora&.strftime('%d/%m/%Y %H:%M:%S')}"
        end
        csv_data = lines.join("\n")

        send_data csv_data, filename: "leituras_harvestpoint_#{Date.current}.csv", type: "text/csv; charset=utf-8"
        return
      end

      limit = params[:limit].present? ? params[:limit].to_i : 100
      total = leituras.count
      leituras = leituras.limit(limit)

      render json: {
        total: total,
        data: leituras.map(&:as_json_public)
      }, status: :ok
    end

    def create
      # Permite envio direto para /api/leituras tanto de simuladores quanto de ESP-32
      sensor_id = params[:sensor_id]
      codigo = params[:codigo] || params[:sensor_codigo]

      sensor = if sensor_id.present?
                 Sensor.find_by(id: sensor_id)
               elsif codigo.present?
                 Sensor.find_by(codigo: codigo)
               else
                 Sensor.first
               end

      unless sensor
        return render json: { error: "sensor_not_found", message: "Sensor não especificado ou não encontrado" }, status: :not_found
      end

      temp = (params[:temperatura] || params[:temp]).to_s.tr(",", ".").to_f
      umid = (params[:umidade] || params[:umid]).to_s.tr(",", ".").to_f
      data_hora = params[:data_hora].present? ? Time.zone.parse(params[:data_hora].to_s) : Time.current

      leitura = sensor.leitura_sensores.new(
        temperatura: temp,
        umidade: umid,
        data_hora: data_hora
      )

      if leitura.save
        render json: {
          data: leitura.as_json_public,
          message: "Leitura registrada com sucesso",
          alertas_gerados: sensor.alertas.where(data_hora: data_hora).map(&:as_json_public)
        }, status: :created
      else
        render_validation_errors(leitura)
      end
    end
  end
end
