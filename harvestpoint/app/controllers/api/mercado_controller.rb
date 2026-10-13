module Api
  class MercadoController < ApplicationController
    before_action :authenticate_user!

    def index
      precos = PrecoMercado.includes(:cultura).order(data_cotacao: :desc)
      dolar_ptax = BancoCentralService.cotacao_dolar
      euro_ptax = BancoCentralService.cotacao_euro

      taxa_dolar = (dolar_ptax && dolar_ptax[:venda].to_f > 0) ? dolar_ptax[:venda].to_f : 5.42

      exportacao_produtos = ComexStatService.dados_exportacao.map do |p|
        usd_kg = p[:preco_medio_usd_kg].to_f
        brl_kg = (usd_kg * taxa_dolar).round(2)
        {
          produto: p[:produto],
          ncm: p[:ncm],
          preco_usd_kg: usd_kg,
          preco_brl_kg: brl_kg
        }
      end

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
        end,
        dolar: dolar_ptax,
        euro: euro_ptax,
        exportacao: exportacao_produtos
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
