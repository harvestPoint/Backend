class Alerta < ApplicationRecord
  SEVERIDADES = %w[critico atencao informacao].freeze
  STATUSES = %w[aberto em_analise resolvido informativo].freeze

  belongs_to :user
  belongs_to :lote, optional: true
  belongs_to :sensor, optional: true
  belongs_to :leitura, optional: true

  scope :ativos, -> { where.not(status: "resolvido") }

  before_validation :normalize_fields
  before_save :registrar_resolucao

  validates :titulo, presence: true
  validates :severidade, inclusion: { in: SEVERIDADES }
  validates :status, inclusion: { in: STATUSES }

  def as_json_public
    {
      id: id,
      severidade: severidade,
      status: status,
      titulo: titulo,
      grandeza: grandeza,
      direcao: direcao,
      valor: valor&.to_f,
      limite: limite&.to_f,
      lote: lote && { id: lote.id, codigo: lote.codigo },
      sensor: sensor && { id: sensor.id, codigo: sensor.codigo },
      registrado_em: created_at,
      resolvido_em: resolvido_em
    }
  end

  private

  def normalize_fields
    self.status = status.presence || "aberto"
  end

  def registrar_resolucao
    self.resolvido_em = status == "resolvido" ? Time.current : nil if status_changed?
  end
end
