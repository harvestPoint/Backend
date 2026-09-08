class Cultura < ApplicationRecord
  has_many :lotes, dependent: :restrict_with_error

  validates :nome, presence: true
  validate :faixa_temperatura_valida
  validate :faixa_umidade_valida

  private

  def faixa_temperatura_valida
    return if temperatura_min.blank? || temperatura_max.blank?
    return if temperatura_min <= temperatura_max

    errors.add(:temperatura_min, "não pode ser maior que a temperatura máxima")
  end

  def faixa_umidade_valida
    return if umidade_min.blank? || umidade_max.blank?
    return if umidade_min <= umidade_max

    errors.add(:umidade_min, "não pode ser maior que a umidade máxima")
  end
end
