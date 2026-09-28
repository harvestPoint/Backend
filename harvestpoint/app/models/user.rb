class User < ApplicationRecord
  has_secure_password

  has_many :lotes, dependent: :destroy

  ROLES = %w[proprietario tecnico].freeze

  before_validation :normalize_email
  before_validation :default_role

  validates :nome, presence: true
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 8 }, allow_nil: true
  validates :role, inclusion: { in: ROLES }
  validates :propriedade, presence: true

  def issue_api_token!
    raw = SecureRandom.hex(32)
    update!(api_token_digest: self.class.digest_token(raw))
    raw
  end

  def clear_api_token!
    update!(api_token_digest: nil)
  end

  def self.find_by_api_token(raw)
    return if raw.blank?

    find_by(api_token_digest: digest_token(raw))
  end

  def self.digest_token(raw)
    Digest::SHA256.hexdigest(raw)
  end

  def as_json_public
    {
      id: id,
      nome: nome,
      email: email,
      role: role,
      propriedade: propriedade
    }
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end

  def default_role
    self.role = role.presence || "proprietario"
  end
end
