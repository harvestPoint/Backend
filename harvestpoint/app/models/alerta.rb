class Alerta < ApplicationRecord
  self.table_name = "alertas"

  belongs_to :sensor

  validates :tipo, presence: true, length: { maximum: 50 }
  validates :mensagem, presence: true
  validates :data_hora, presence: true
  validates :resolvido, inclusion: { in: [true, false] }

  def resolver!
    update!(resolvido: true)
  end

  def as_json_public
    {
      id: id,
      sensor_id: sensor_id,
      sensor_codigo: sensor&.codigo,
      lote_id: sensor&.lote_id,
      lote_nome: sensor&.lote&.nome,
      propriedade: sensor&.lote&.propriedade&.nome,
      cultura: sensor&.lote&.cultura_ativa&.nome,
      tipo: tipo,
      severidade: tipo.include?("ALTA") || tipo.include?("ESTRESSE") ? "crítico" : "aviso",
      mensagem: mensagem,
      data_hora: data_hora&.iso8601,
      resolvido: resolvido
    }
  end
end
