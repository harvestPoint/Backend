class Lote < ApplicationRecord
  self.table_name = "lotes"

  belongs_to :propriedade
  has_one :usuario, through: :propriedade

  has_many :historico_cultivos, dependent: :destroy
  has_many :culturas, through: :historico_cultivos
  has_many :sensores, class_name: "Sensor", dependent: :destroy
  has_many :recomendacao_colheitas, dependent: :destroy

  validates :nome, presence: true, length: { maximum: 100 }
  validates :area, presence: true, numericality: { greater_than: 0 }

  attr_accessor :cultura_temp, :variedade_temp, :data_plantio_temp, :sensor_vinculado_temp, :status_temp

  before_validation :garantir_propriedade
  after_save :salvar_vinculos_temporarios

  def codigo
    nome
  end

  def codigo=(val)
    self.nome = val
  end

  def area_ha
    area.to_f
  end

  def area_ha=(val)
    parsed = val.is_a?(String) ? val.tr(",", ".").to_f : val.to_f
    self.area = parsed
  end

  def user_id
    propriedade&.usuario_id
  end

  def propriedade=(val)
    if val.is_a?(Propriedade)
      super
    elsif val.present?
      prop = Propriedade.where("LOWER(nome) = ?", val.to_s.strip.downcase).first
      prop ||= Propriedade.create!(
        usuario: Usuario.first,
        nome: val.to_s.strip,
        municipio: "Petrolina - PE",
        latitude: -9.3891,
        longitude: -40.5027,
        area_total: 100.00
      )
      self.propriedade = prop
    end
  end

  def cultura=(val)
    @cultura_temp = val
  end

  def variedade=(val)
    @variedade_temp = val
  end

  def data_plantio=(val)
    @data_plantio_temp = val
  end

  def sensor_vinculado=(val)
    @sensor_vinculado_temp = val
  end

  def status=(val)
    @status_temp = val.to_s
    if historico_ativo
      historico_ativo.update(status: (val.to_s.upcase == "FINALIZADO" ? "FINALIZADO" : val.to_s))
    end
  end

  def status
    @status_temp.presence || historico_ativo&.status || "ativo"
  end

  def historico_ativo
    historico_cultivos.find_by(status: "ATIVO") || historico_cultivos.order(data_plantio: :desc).first
  end

  def cultura_ativa
    historico_ativo&.cultura
  end

  def sensor_principal
    sensores.find_by(status: "ATIVO") || sensores.first
  end

  def ultima_leitura
    sensores.joins(:leitura_sensores).order("leitura_sensores.data_hora DESC").first&.leitura_sensores&.order(data_hora: :desc)&.first
  end

  def as_json_public
    hist = historico_ativo
    cult = hist&.cultura
    sens = sensor_principal
    ult = ultima_leitura

    {
      id: id,
      propriedade_id: propriedade_id,
      propriedade: propriedade&.nome,
      municipio: propriedade&.municipio,
      nome: nome,
      codigo: nome,
      area: area.to_f,
      area_ha: area.to_f,
      cultura_id: cult&.id,
      cultura: cult&.nome || "Não definida",
      variedade: cult&.nome || "Padrão",
      data_plantio: hist&.data_plantio&.to_s,
      data_fim_ciclo: hist&.data_fim_ciclo&.to_s,
      status: @status_temp.presence || hist&.status || status,
      sensor_vinculado: sens&.codigo,
      sensores_count: sensores.count,
      ultima_temperatura: ult&.temperatura&.to_f,
      ultima_umidade: ult&.umidade&.to_f,
      ultima_leitura_em: ult&.data_hora&.iso8601,
      alertas_ativos_count: sensores.joins(:alertas).where(alertas: { resolvido: false }).count,
      recomendacao_atual: recomendacao_colheitas.order(data_atualizacao: :desc).first&.as_json_public
    }
  end

  private

  def garantir_propriedade
    return if propriedade_id.present? || propriedade.present?

    u = Usuario.first
    self.propriedade = u&.propriedades&.first || u&.propriedades&.create!(
      nome: "Fazenda Padrão",
      municipio: "Petrolina - PE",
      latitude: -9.3891,
      longitude: -40.5027,
      area_total: 100.00
    )
  end

  def salvar_vinculos_temporarios
    cult_nome = (@cultura_temp.presence || @variedade_temp).to_s.strip
    if cult_nome.present? || @data_plantio_temp.present?
      cult = Cultura.where("LOWER(nome) = ?", cult_nome.downcase).first if cult_nome.present?
      cult ||= Cultura.create!(
        nome: cult_nome.presence || "Cultura Geral",
        ciclo_medio_dias: 120,
        temperatura_min: 20.0,
        temperatura_max: 35.0,
        umidade_min: 40.0,
        umidade_max: 70.0
      )

      hist = historico_ativo || historico_cultivos.new
      hist.cultura = cult
      hist.data_plantio = @data_plantio_temp.presence || hist.data_plantio || Date.current
      hist.status = (@status_temp.to_s.upcase == "FINALIZADO" ? "FINALIZADO" : "ATIVO")
      hist.save!
    elsif @status_temp.present? && historico_ativo
      historico_ativo.update(status: (@status_temp.to_s.upcase == "FINALIZADO" ? "FINALIZADO" : "ATIVO"))
    end

    if @sensor_vinculado_temp.present?
      sens_codigo = @sensor_vinculado_temp.to_s.strip
      sensor = Sensor.find_by(codigo: sens_codigo)
      if sensor
        sensor.update(lote_id: id)
      else
        sensores.create(codigo: sens_codigo, status: "ATIVO")
      end
    end
  end
end
