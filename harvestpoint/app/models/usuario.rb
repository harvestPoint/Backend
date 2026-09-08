class Usuario < ApplicationRecord
  TIPO_PRODUTOR = "produtor"
  STATUS_ATIVO = "ativo"

  belongs_to :produtor, optional: true

  has_secure_password

  before_validation :normalizar_cpf
  before_validation :normalizar_email
  before_validation :definir_padroes_mvp

  validates :nome, presence: true
  validates :cpf, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :tipo_usuario, presence: true, inclusion: { in: [ TIPO_PRODUTOR ] }
  validates :status, presence: true
  validate :cpf_deve_ser_valido

  def ativo?
    status == STATUS_ATIVO
  end

  def as_json(options = {})
    super({ except: [ :password_digest ] }.merge(options))
  end

  private

  def normalizar_cpf
    self.cpf = cpf.to_s.gsub(/\D/, "")
  end

  def normalizar_email
    self.email = email.to_s.downcase.strip.presence
  end

  def definir_padroes_mvp
    self.tipo_usuario = TIPO_PRODUTOR if tipo_usuario.blank?
    self.status = STATUS_ATIVO if status.blank?
  end

  def cpf_deve_ser_valido
    return if cpf.blank?
    return if DocumentoBrasil.cpf_valido?(cpf)

    errors.add(:cpf, "é inválido")
  end
end
