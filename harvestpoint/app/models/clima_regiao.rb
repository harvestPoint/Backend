class ClimaRegiao < ApplicationRecord
  self.table_name = "clima_regioes"

  belongs_to :propriedade

  validates :data_previsao, presence: true
  validates :temperatura_min, presence: true, numericality: true
  validates :temperatura_max, presence: true, numericality: true
  validates :chance_chuva_percentual, presence: true, numericality: { in: 0..100 }
  validates :precipitacao_mm, numericality: true, allow_nil: true

  def as_json_public
    {
      id: id,
      propriedade_id: propriedade_id,
      propriedade_nome: propriedade&.nome,
      municipio: propriedade&.municipio,
      data_previsao: data_previsao&.to_s,
      temperatura_min: temperatura_min.to_f,
      temperatura_max: temperatura_max.to_f,
      chance_chuva_percentual: chance_chuva_percentual.to_f,
      precipitacao_mm: precipitacao_mm&.to_f
    }
  end
end
