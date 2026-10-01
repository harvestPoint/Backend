class PrecoMercado < ApplicationRecord
  self.table_name = "preco_mercados"

  belongs_to :cultura

  validates :preco_medio, presence: true, numericality: { greater_than: 0 }
  validates :moeda, presence: true, length: { maximum: 3 }
  validates :data_cotacao, presence: true

  def as_json_public
    {
      id: id,
      cultura_id: cultura_id,
      cultura_nome: cultura&.nome,
      preco_medio: preco_medio.to_f,
      moeda: moeda,
      data_cotacao: data_cotacao&.to_s
    }
  end
end
