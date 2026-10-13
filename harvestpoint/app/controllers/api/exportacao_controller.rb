module Api
  class ExportacaoController < ApplicationController
    before_action :authenticate_user!

    def index
      produtos = ComexStatService.dados_exportacao

      # Cruzamento com as recomendações de colheita dos lotes do usuário
      minhas_janelas = []
      current_user.lotes_visiveis.each do |lote|
        rec = lote.recomendacao_colheitas.order(data_atualizacao: :desc).first
        next unless rec

        cultura_nome = lote.cultura_ativa&.nome || ""
        produto_correspondente = produtos.find { |p| cultura_nome.downcase.include?(p[:produto].downcase) }

        # Meses abrangidos pela janela de colheita
        mes_inicio = rec.data_inicio.month
        mes_fim = rec.data_fim.month
        meses_colheita = (mes_inicio..mes_fim).to_a
        meses_colheita = [mes_inicio, mes_fim].uniq if mes_inicio > mes_fim # virada de ano

        picos = produto_correspondente ? produto_correspondente[:meses_pico] : []
        em_alta = (meses_colheita & picos).any?

        minhas_janelas << rec.as_json_public.merge(
          lote_nome: lote.nome,
          cultura: cultura_nome,
          produto_exportacao: produto_correspondente ? produto_correspondente[:produto] : nil,
          meses_colheita: meses_colheita,
          em_alta_demanda: em_alta
        )
      end

      render json: {
        data: produtos,
        minhas_janelas: minhas_janelas
      }, status: :ok
    end
  end
end
