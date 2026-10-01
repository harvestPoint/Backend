class HistoricoCultivo < ApplicationRecord
  self.table_name = "historico_cultivos"

  belongs_to :lote
  belongs_to :cultura

  STATUSES = %w[ATIVO FINALIZADO].freeze

  validates :data_plantio, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def as_json_public
    {
      id: id,
      lote_id: lote_id,
      lote_nome: lote&.nome,
      cultura_id: cultura_id,
      cultura_nome: cultura&.nome,
      data_plantio: data_plantio&.to_s,
      data_fim_ciclo: data_fim_ciclo&.to_s,
      status: status,
      dias_desde_plantio: data_plantio ? (Date.current - data_plantio).to_i : 0,
      ciclo_total_dias: cultura&.ciclo_medio_dias
    }
  end
end
