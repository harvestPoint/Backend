class Leitura < ApplicationRecord
  MEDIDAS = %w[temperatura umidade_ar umidade_solo precipitacao].freeze
  ORIGENS = %w[sensor manual simulador].freeze
  # Leituras mais antigas que isso (ex.: importação de histórico) não geram alerta.
  JANELA_PARA_ALERTA = 2.hours

  belongs_to :sensor
  belongs_to :lote, optional: true
  has_many :alertas, dependent: :nullify

  before_validation :preencher_defaults, on: :create

  validates :origem, inclusion: { in: ORIGENS }
  validates :temperatura, numericality: { greater_than_or_equal_to: -50, less_than_or_equal_to: 80 }, allow_nil: true
  validates :umidade_ar, :umidade_solo,
            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :precipitacao, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validate :ao_menos_uma_medida
  validate :medido_em_nao_esta_no_futuro
  validate :lote_pertence_ao_mesmo_usuario_do_sensor

  after_create :atualizar_sensor
  after_create :gerar_alertas

  def as_json_public
    {
      id: id,
      sensor: { id: sensor.id, codigo: sensor.codigo },
      lote: lote && { id: lote.id, codigo: lote.codigo },
      medido_em: medido_em,
      temperatura: temperatura&.to_f,
      umidade_ar: umidade_ar&.to_f,
      umidade_solo: umidade_solo&.to_f,
      precipitacao: precipitacao&.to_f,
      origem: origem
    }
  end

  private

  def preencher_defaults
    self.medido_em ||= Time.current
    self.lote ||= sensor&.lote
    self.origem = origem.presence || "sensor"
  end

  def ao_menos_uma_medida
    errors.add(:base, "Informe ao menos uma medida") if MEDIDAS.none? { |m| self[m].present? }
  end

  def medido_em_nao_esta_no_futuro
    errors.add(:medido_em, "não pode estar no futuro") if medido_em && medido_em > 5.minutes.from_now
  end

  def lote_pertence_ao_mesmo_usuario_do_sensor
    return if lote.nil? || sensor.nil?

    errors.add(:lote, "precisa pertencer ao mesmo usuário do sensor") if lote.user_id != sensor.user_id
  end

  def atualizar_sensor
    return if sensor.ultima_leitura_em && sensor.ultima_leitura_em >= medido_em

    sensor.update_columns(ultima_leitura_em: medido_em, updated_at: Time.current)
  end

  def gerar_alertas
    AlertaGerador.new(self).call
  end
end
