class Lote < ApplicationRecord
  # Evolução prevista (não implementada nesta fase):
  # Lote has_many :sensores → Sensor has_many :leituras_sensor → Alertas
  belongs_to :propriedade
  belongs_to :cultura

  validates :nome, presence: true
  validates :situacao, presence: true
  validate :previsao_colheita_apos_plantio

  private

  def previsao_colheita_apos_plantio
    return if data_plantio.blank? || previsao_colheita.blank?
    return if previsao_colheita >= data_plantio

    errors.add(:previsao_colheita, "não pode ser anterior à data de plantio")
  end
end
