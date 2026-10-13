require "net/http"
require "json"
require "uri"

module BancoCentralService
  CACHE_DURATION = 30.minutes
  @cache = {}

  class << self
    def cotacao_dolar
      cached = read_cache(:usd)
      return cached if cached

      # Tenta buscar dos últimos 5 dias úteis caso hoje seja fim de semana/feriado
      data = buscar_cotacao_moeda("USD") || fallback_dolar
      write_cache(:usd, data)
      data
    end

    def cotacao_euro
      cached = read_cache(:eur)
      return cached if cached

      data = buscar_cotacao_moeda("EUR") || fallback_euro
      write_cache(:eur, data)
      data
    end

    private

    def buscar_cotacao_moeda(moeda)
      hoje = Date.current
      (0..5).each do |dias_atras|
        data_consulta = hoje - dias_atras.days
        next if data_consulta.saturday? || data_consulta.sunday?

        data_formatada = data_consulta.strftime("%m-%d-%Y")
        resultado = requisitar_ptax(moeda, data_formatada)
        return resultado if resultado
      end
      nil
    rescue StandardError => e
      Rails.logger.warn("[BancoCentralService] Falha ao consultar PTAX #{moeda}: #{e.message}")
      nil
    end

    def requisitar_ptax(moeda, data_formatada)
      uri = if moeda == "USD"
              URI("https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoDolarDia(dataCotacao=@dataCotacao)?@dataCotacao='#{data_formatada}'&$top=1&$format=json")
            else
              URI("https://olinda.bcb.gov.br/olinda/servico/PTAX/versao/v1/odata/CotacaoMoedaDia(moeda=@moeda,dataCotacao=@dataCotacao)?@moeda='#{moeda}'&@dataCotacao='#{data_formatada}'&$top=1&$format=json")
            end

      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 3
      http.read_timeout = 3

      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      response = http.request(request)

      return nil unless response.is_a?(Net::HTTPSuccess)

      json = JSON.parse(response.body)
      cotacoes = json["value"]
      return nil if cotacoes.blank?

      ultima = cotacoes.last
      {
        moeda: moeda,
        compra: ultima["cotacaoCompra"]&.to_f&.round(4),
        venda: ultima["cotacaoVenda"]&.to_f&.round(4),
        data_hora: ultima["dataHoraCotacao"],
        boletim: "Fechamento Oficial PTAX - Banco Central",
        fonte: "api"
      }
    rescue StandardError
      nil
    end

    def fallback_dolar
      {
        moeda: "USD",
        compra: 5.4180,
        venda: 5.4240,
        data_hora: Time.current.iso8601,
        boletim: "Referência PTAX (Estimada / Contingência)",
        fonte: "cache"
      }
    end

    def fallback_euro
      {
        moeda: "EUR",
        compra: 5.8820,
        venda: 5.8910,
        data_hora: Time.current.iso8601,
        boletim: "Referência PTAX (Estimada / Contingência)",
        fonte: "cache"
      }
    end

    def read_cache(key)
      item = @cache[key]
      return nil unless item
      return nil if Time.current > item[:expires_at]

      item[:data]
    end

    def write_cache(key, data)
      @cache[key] = {
        data: data,
        expires_at: Time.current + CACHE_DURATION
      }
    end
  end
end
