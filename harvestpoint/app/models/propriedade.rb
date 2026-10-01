class Propriedade < ApplicationRecord
  self.table_name = "propriedades"

  belongs_to :usuario, foreign_key: :usuario_id
  has_many :lotes, dependent: :destroy
  has_many :clima_regioes, class_name: "ClimaRegiao", dependent: :destroy

  validates :nome, presence: true, length: { maximum: 150 }
  validates :municipio, presence: true, length: { maximum: 100 }
  validates :latitude, presence: true, numericality: true
  validates :longitude, presence: true, numericality: true
  validates :area_total, presence: true, numericality: { greater_than: 0 }

  def as_json_public
    {
      id: id,
      usuario_id: usuario_id,
      produtor: usuario&.nome,
      nome: nome,
      municipio: municipio,
      latitude: latitude.to_f,
      longitude: longitude.to_f,
      area_total: area_total.to_f,
      total_lotes: lotes.count,
      created_at: created_at&.iso8601
    }
  end
end
