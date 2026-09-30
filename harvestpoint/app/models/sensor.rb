class Sensor < ApplicationRecord
  GRANDEZAS = %w[temperatura umidade_ar umidade_solo precipitacao].freeze

  belongs_to :user
  belongs_to :lote, optional: true
  has_many :leituras, dependent: :destroy
  has_many :alertas, dependent: :nullify

  has_secure_token :token

  before_validation :normalize_fields

  validates :codigo, presence: true, uniqueness: { scope: :user_id, case_sensitive: false }
  validate :grandezas_validas
  validate :lote_pertence_ao_mesmo_usuario

  # on-line: leitura nas últimas 2 h · instável: até 12 h · off-line: mais antiga ou nunca.
  def status_operacional(agora = Time.current)
    return "off-line" if ultima_leitura_em.nil?

    idade = agora - ultima_leitura_em
    if idade <= 2.hours then "on-line"
    elsif idade <= 12.hours then "instável"
    else "off-line"
    end
  end

  def as_json_public
    {
      id: id,
      codigo: codigo,
      grandezas: grandezas,
      propriedade: user.propriedade,
      lote: lote && { id: lote.id, codigo: lote.codigo },
      instalado_em: instalado_em,
      ultima_leitura_em: ultima_leitura_em,
      status: status_operacional,
      created_at: created_at,
      updated_at: updated_at
    }
  end

  private

  def normalize_fields
    self.codigo = codigo.to_s.strip
    self.grandezas = Array(grandezas).map { |g| g.to_s.strip }.reject(&:blank?).uniq
  end

  def grandezas_validas
    invalidas = grandezas - GRANDEZAS
    errors.add(:grandezas, "inválidas: #{invalidas.join(', ')}") if invalidas.any?
  end

  def lote_pertence_ao_mesmo_usuario
    return if lote.nil?

    errors.add(:lote, "precisa pertencer ao mesmo usuário do sensor") if lote.user_id != user_id
  end
end
