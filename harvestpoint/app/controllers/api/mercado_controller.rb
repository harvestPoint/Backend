module Api
  class MercadoController < ApplicationController
    before_action :authenticate_user!

    def index
      precos = PrecoMercado.includes(:cultura).order(data_cotacao: :desc)
      render json: {
        data: precos.map(&:as_json_public),
        resumo_culturas: Cultura.all.map do |c|
          ultima = c.preco_mercados.order(data_cotacao: :desc).first
          {
            cultura_id: c.id,
            cultura_nome: c.nome,
            preco_medio: ultima&.preco_medio&.to_f || 0.0,
            moeda: ultima&.moeda || "BRL",
            data_cotacao: ultima&.data_cotacao&.to_s
          }
        end
      }, status: :ok
    end

    def create
      cultura_id = params[:cultura_id]
      preco = params[:preco_medio].to_s.tr(",", ".").to_f
      moeda = params[:moeda].presence || "BRL"
      data = params[:data_cotacao].presence || Date.current

      cotacao = PrecoMercado.create!(
        cultura_id: cultura_id,
        preco_medio: preco,
        moeda: moeda.upcase,
        data_cotacao: data
      )

      render json: { data: cotacao.as_json_public, message: "Cotação registrada com sucesso" }, status: :created
    end
  end
end
