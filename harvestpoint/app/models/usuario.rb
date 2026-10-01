require "bcrypt"

class Usuario < ApplicationRecord
  self.table_name = "usuarios"

  has_many :propriedades, dependent: :destroy, foreign_key: :usuario_id
  has_many :lotes, through: :propriedades do
    def create!(attributes = {}, &block)
      prop = proxy_association.owner.propriedades.first || proxy_association.owner.propriedades.create!(
        nome: attributes[:propriedade].presence || "Propriedade Principal",
        municipio: "Petrolina - PE",
        latitude: -9.3891,
        longitude: -40.5027,
        area_total: 100.00
      )
      prop.lotes.create!(attributes, &block)
    end

    def create(attributes = {}, &block)
      prop = proxy_association.owner.propriedades.first || proxy_association.owner.propriedades.create!(
        nome: attributes[:propriedade].presence || "Propriedade Principal",
        municipio: "Petrolina - PE",
        latitude: -9.3891,
        longitude: -40.5027,
        area_total: 100.00
      )
      prop.lotes.create(attributes, &block)
    end

    def new(attributes = {}, &block)
      prop = proxy_association.owner.propriedades.first || proxy_association.owner.propriedades.build(
        nome: attributes[:propriedade].presence || "Propriedade Principal",
        municipio: "Petrolina - PE",
        latitude: -9.3891,
        longitude: -40.5027,
        area_total: 100.00
      )
      prop.lotes.new(attributes, &block)
    end

    def build(attributes = {}, &block)
      new(attributes, &block)
    end
  end

  TIPOS_USUARIO = %w[PRODUTOR TECNICO].freeze

  attr_accessor :password

  before_validation :normalize_fields
  before_validation :hash_password, if: -> { password.present? }
  before_validation :set_defaults

  validates :nome, presence: true, length: { maximum: 150 }
  validates :email, presence: true,
                    length: { maximum: 150 },
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf_cnpj, presence: true, length: { maximum: 20 }, uniqueness: { case_sensitive: false }
  validates :telefone, presence: true, length: { maximum: 20 }
  validates :tipo_usuario, presence: true, inclusion: { in: TIPOS_USUARIO }
  validates :senha_hash, presence: true
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
  validate :password_required_on_create

  def authenticate(unencrypted_password)
    return false if senha_hash.blank? || unencrypted_password.blank?

    BCrypt::Password.new(senha_hash).is_password?(unencrypted_password.to_s) ? self : false
  rescue BCrypt::Errors::BcryptError
    false
  end

  def role
    tipo_usuario == "TECNICO" ? "tecnico" : "proprietario"
  end

  def role=(val)
    self.tipo_usuario = val.to_s.upcase == "TECNICO" || val.to_s.downcase == "tecnico" ? "TECNICO" : "PRODUTOR"
  end

  def propriedade
    @propriedade_temp || propriedades.first&.nome
  end

  def propriedade=(val)
    @propriedade_temp = val.to_s.strip if val.present?
  end

  after_save :salvar_propriedade_temp

  def issue_api_token!
    raw = SecureRandom.hex(32)
    update_column(:api_token_digest, self.class.digest_token(raw))
    raw
  end

  def clear_api_token!
    update_column(:api_token_digest, nil)
  end

  def self.find_by_api_token(raw)
    return if raw.blank?

    find_by(api_token_digest: digest_token(raw))
  end

  def self.digest_token(raw)
    Digest::SHA256.hexdigest(raw)
  end

  def tecnico?
    tipo_usuario == "TECNICO"
  end

  def propriedades_visiveis
    tecnico? ? Propriedade.all : propriedades
  end

  def lotes_visiveis
    Lote.joins(:propriedade).where(propriedades: { id: propriedades_visiveis.select(:id) })
  end

  def sensores_visiveis
    Sensor.where(lote_id: lotes_visiveis.select(:id))
  end

  def as_json_public
    {
      id: id,
      nome: nome,
      email: email,
      cpf_cnpj: cpf_cnpj,
      telefone: telefone,
      tipo_usuario: tipo_usuario,
      role: role,
      propriedade: propriedade,
      data_cadastro: data_cadastro&.iso8601
    }
  end

  private

  def normalize_fields
    self.email = email.to_s.strip.downcase
    self.nome = nome.to_s.strip
    self.cpf_cnpj = cpf_cnpj.to_s.strip
    self.telefone = telefone.to_s.strip
  end

  def set_defaults
    self.data_cadastro ||= Time.current
    self.tipo_usuario = tipo_usuario.presence || "PRODUTOR"
    self.cpf_cnpj = cpf_cnpj.presence || "#{rand(100..999)}.#{rand(100..999)}.#{rand(100..999)}-#{rand(10..99)}"
    self.telefone = telefone.presence || "(87) 99999-0000"
  end

  def hash_password
    self.senha_hash = BCrypt::Password.create(password)
  end

  def password_required_on_create
    if new_record? && senha_hash.blank? && password.blank?
      errors.add(:password, "não pode ficar em branco")
    end
  end

  def salvar_propriedade_temp
    if @propriedade_temp.present? && !propriedades.exists?(nome: @propriedade_temp)
      propriedades.create!(
        nome: @propriedade_temp,
        municipio: "Petrolina - PE",
        latitude: -9.3891,
        longitude: -40.5027,
        area_total: 100.00
      )
    end
  end
end
