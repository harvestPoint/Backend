class Lote < ApplicationRecord
  belongs_to :user
  has_many :sensores, dependent: :nullify
  has_many :leituras, dependent: :nullify
  has_many :alertas, dependent: :destroy

  STATUSES = %w[ativo em_manejo inativo].freeze

  before_validation :normalize_fields

  validates :codigo, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validates :propriedade, :cultura, :variedade, presence: true
  validates :area_ha, numericality: { greater_than: 0 }
  validates :status, inclusion: { in: STATUSES }

  def area_ha=(val)
    if val.is_a?(String)
      super(val.tr(",", "."))
    else
      super(val)
    end
  end

  def as_json_public
    {
      id: id,
      codigo: codigo,
      propriedade: propriedade,
      cultura: cultura,
      variedade: variedade,
      area_ha: area_ha&.to_f,
      data_plantio: data_plantio,
      sensor_vinculado: sensor_vinculado,
      status: status,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def normalize_fields
    self.codigo = codigo.to_s.strip
    self.propriedade = propriedade.to_s.strip
    self.cultura = cultura.to_s.strip
    self.variedade = variedade.to_s.strip
    self.sensor_vinculado = sensor_vinculado.to_s.strip.presence
    self.status = status.to_s.strip.presence || "ativo"
  end
end
