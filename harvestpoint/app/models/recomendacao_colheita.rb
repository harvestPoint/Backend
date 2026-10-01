class RecomendacaoColheita < ApplicationRecord
  self.table_name = "recomendacao_colheitas"

  belongs_to :lote

  STATUSES = %w[PENDENTE ACEITA REJEITADA].freeze

  validates :data_inicio, presence: true
  validates :data_fim, presence: true
  validates :grau_confianca, presence: true, numericality: { in: 0..100 }
  validates :data_atualizacao, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def aceitar!
    update!(status: "ACEITA", data_atualizacao: Time.current)
  end

  def rejeitar!
    update!(status: "REJEITADA", data_atualizacao: Time.current)
  end

  def as_json_public
    hist = lote&.historico_ativo
    cult = hist&.cultura
    dias_decorridos = hist&.data_plantio ? (Date.current - hist.data_plantio).to_i : 0
    ciclo = cult&.ciclo_medio_dias || 120

    {
      id: id,
      lote_id: lote_id,
      lote_nome: lote&.nome,
      propriedade: lote&.propriedade&.nome,
      cultura: cult&.nome || "Não informada",
      data_inicio: data_inicio&.to_s,
      data_fim: data_fim&.to_s,
      grau_confianca: grau_confianca.to_f,
      data_atualizacao: data_atualizacao&.iso8601,
      status: status,
      dias_decorridos: dias_decorridos,
      ciclo_medio_dias: ciclo,
      dias_restantes: [ciclo - dias_decorridos, 0].max
    }
  end
end
