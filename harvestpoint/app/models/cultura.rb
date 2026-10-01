class Cultura < ApplicationRecord
  self.table_name = "culturas"

  has_many :historico_cultivos, dependent: :destroy
  has_many :preco_mercados, dependent: :destroy
  has_many :lotes, through: :historico_cultivos

  validates :nome, presence: true, length: { maximum: 100 }
  validates :ciclo_medio_dias, presence: true, numericality: { greater_than: 0 }
  validates :temperatura_min, presence: true, numericality: true
  validates :temperatura_max, presence: true, numericality: true
  validates :umidade_min, presence: true, numericality: true
  validates :umidade_max, presence: true, numericality: true

  def as_json_public
    {
      id: id,
      nome: nome,
      ciclo_medio_dias: ciclo_medio_dias,
      temperatura_min: temperatura_min.to_f,
      temperatura_max: temperatura_max.to_f,
      umidade_min: umidade_min.to_f,
      umidade_max: umidade_max.to_f,
      cotacao_atual: preco_mercados.order(data_cotacao: :desc).first&.preco_medio&.to_f,
      moeda: preco_mercados.order(data_cotacao: :desc).first&.moeda || "BRL"
    }
  end
end
