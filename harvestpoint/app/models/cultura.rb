# Catálogo de referência (não pertence a nenhum usuário): usado para exibir as
# faixas ideais na tela de Culturas e para o AlertaGerador comparar leituras.
# O campo `cultura`/`variedade` do Lote continua sendo texto livre — se não
# houver Cultura cadastrada com o mesmo nome+variedade, simplesmente não há
# faixa ideal conhecida e nenhum alerta automático é gerado para aquele lote.
class Cultura < ApplicationRecord
  MEDIDAS = %w[temperatura umidade_ar umidade_solo].freeze

  before_validation :normalize_fields

  validates :nome, :variedade, presence: true
  validates :variedade, uniqueness: { scope: :nome, case_sensitive: false }
  validates :ciclo_dias, numericality: { only_integer: true, greater_than: 0 }
  validate :faixas_coerentes

  def self.para(nome, variedade)
    find_by("lower(nome) = ? AND lower(variedade) = ?", nome.to_s.strip.downcase, variedade.to_s.strip.downcase)
  end

  # Lotes (de qualquer usuário) que usam este nome+variedade — apenas para o
  # contador "lotes usando" na tela de Culturas; não é uma associação real de FK.
  def lotes
    Lote.where("lower(cultura) = ? AND lower(variedade) = ?", nome.downcase, variedade.downcase)
  end

  # [min, max] da grandeza, ou nil se a cultura não define faixa para ela.
  def faixa(medida)
    return unless MEDIDAS.include?(medida.to_s)

    min = self[:"#{medida}_min"]
    max = self[:"#{medida}_max"]
    [ min, max ] unless min.nil? && max.nil?
  end

  # "acima", "abaixo" ou nil (dentro da faixa, ou sem faixa cadastrada).
  def desvio(medida, valor)
    min, max = faixa(medida)
    return if valor.nil?

    if max && valor > max then "acima"
    elsif min && valor < min then "abaixo"
    end
  end

  def as_json_public
    {
      id: id,
      nome: nome,
      variedade: variedade,
      ciclo_dias: ciclo_dias,
      temperatura: faixa_json("temperatura"),
      umidade_ar: faixa_json("umidade_ar"),
      umidade_solo: faixa_json("umidade_solo"),
      lotes_usando: lotes.count
    }
  end

  private

  def faixa_json(medida)
    min, max = faixa(medida)
    { min: min&.to_f, max: max&.to_f }
  end

  def normalize_fields
    self.nome = nome.to_s.strip
    self.variedade = variedade.to_s.strip
  end

  def faixas_coerentes
    MEDIDAS.each do |medida|
      min, max = faixa(medida)
      errors.add(:"#{medida}_max", "deve ser maior ou igual ao mínimo") if min && max && max < min
    end
  end
end
