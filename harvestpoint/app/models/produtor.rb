class Produtor < ApplicationRecord
  has_many :usuarios, dependent: :nullify
  has_many :propriedades, dependent: :restrict_with_error

  before_validation :normalizar_cpf_cnpj

  validates :nome_razao_social, presence: true
  validates :cpf_cnpj, presence: true, uniqueness: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validate :cpf_cnpj_deve_ser_valido

  private

  def normalizar_cpf_cnpj
    self.cpf_cnpj = cpf_cnpj.to_s.gsub(/\D/, "")
  end

  def cpf_cnpj_deve_ser_valido
    return if cpf_cnpj.blank?
    return if DocumentoBrasil.cpf_valido?(cpf_cnpj) || DocumentoBrasil.cnpj_valido?(cpf_cnpj)

    errors.add(:cpf_cnpj, "é inválido")
  end
end
