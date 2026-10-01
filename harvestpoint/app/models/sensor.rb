class Sensor < ApplicationRecord
  self.table_name = "sensores"

  belongs_to :lote
  has_many :leitura_sensores, dependent: :destroy
  has_many :alertas, dependent: :destroy

  STATUSES = %w[ATIVO INATIVO MANUTENCAO].freeze

  validates :codigo, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }
  validates :status, presence: true, inclusion: { in: STATUSES }

  def ultima_leitura
    leitura_sensores.order(data_hora: :desc).first
  end

  def as_json_public
    ult = ultima_leitura
    {
      id: id,
      codigo: codigo,
      lote_id: lote_id,
      lote_nome: lote&.nome,
      propriedade: lote&.propriedade&.nome,
      status: status,
      ultima_temperatura: ult&.temperatura&.to_f,
      ultima_umidade: ult&.umidade&.to_f,
      ultima_leitura_em: ult&.data_hora&.iso8601,
      total_leituras: leitura_sensores.count,
      alertas_pendentes_count: alertas.where(resolvido: false).count
    }
  end
end
