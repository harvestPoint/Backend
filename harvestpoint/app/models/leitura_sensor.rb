class LeituraSensor < ApplicationRecord
  self.table_name = "leitura_sensores"

  belongs_to :sensor

  validates :data_hora, presence: true
  validates :temperatura, presence: true, numericality: true
  validates :umidade, presence: true, numericality: true

  after_create :processar_regras_e_ia

  def as_json_public
    {
      id: id,
      sensor_id: sensor_id,
      sensor_codigo: sensor&.codigo,
      lote_id: sensor&.lote_id,
      lote_nome: sensor&.lote&.nome,
      propriedade: sensor&.lote&.propriedade&.nome,
      cultura: sensor&.lote&.cultura_ativa&.nome,
      temperatura: temperatura.to_f,
      umidade: umidade.to_f,
      data_hora: data_hora&.iso8601
    }
  end

  private

  def processar_regras_e_ia
    lote = sensor&.lote
    return unless lote

    cultura = lote.cultura_ativa
    if cultura
      # 1. Regras de Negócio para Desvios e Alertas
      gerar_alertas_desvio(cultura, lote)
      # 2. Motor de IA para Janela de Colheita
      atualizar_inteligencia_colheita(cultura, lote)
    end
  end

  def gerar_alertas_desvio(cultura, lote)
    t = temperatura.to_f
    u = umidade.to_f

    if t > cultura.temperatura_max.to_f
      sensor.alertas.create!(
        tipo: "TEMPERATURA_ALTA",
        mensagem: "Temperatura de #{t}°C acima do limite máximo (#{cultura.temperatura_max}°C) para #{cultura.nome} no lote #{lote.nome}.",
        data_hora: data_hora || Time.current,
        resolvido: false
      )
    elsif t < cultura.temperatura_min.to_f
      sensor.alertas.create!(
        tipo: "TEMPERATURA_BAIXA",
        mensagem: "Temperatura de #{t}°C abaixo do limite mínimo (#{cultura.temperatura_min}°C) para #{cultura.nome} no lote #{lote.nome}.",
        data_hora: data_hora || Time.current,
        resolvido: false
      )
    end

    if u > cultura.umidade_max.to_f
      sensor.alertas.create!(
        tipo: "UMIDADE_ALTA",
        mensagem: "Umidade de #{u}% acima do limite seguro (#{cultura.umidade_max}%). Risco elevado de doenças fúngicas no lote #{lote.nome}.",
        data_hora: data_hora || Time.current,
        resolvido: false
      )
    elsif u < cultura.umidade_min.to_f
      sensor.alertas.create!(
        tipo: "ESTRESSE_HIDRICO",
        mensagem: "Umidade de #{u}% abaixo do recomendado (#{cultura.umidade_min}%). Estresse hídrico detectado no lote #{lote.nome}.",
        data_hora: data_hora || Time.current,
        resolvido: false
      )
    end
  end

  def atualizar_inteligencia_colheita(cultura, lote)
    historico = lote.historico_ativo
    return unless historico&.data_plantio

    dias_decorridos = (Date.current - historico.data_plantio).to_i
    ciclo_dias = cultura.ciclo_medio_dias

    # Se estiver acima de 60% do ciclo, a IA gera/atualiza recomendação de colheita
    if dias_decorridos >= (ciclo_dias * 0.6)
      dias_restantes = [ciclo_dias - dias_decorridos, 2].max
      inicio = Date.current + [dias_restantes - 4, 1].max.days
      fim = inicio + 7.days

      # Confiança baseada na estabilidade térmica e umidade atual
      temp_ok = temperatura.between?(cultura.temperatura_min, cultura.temperatura_max)
      umid_ok = umidade.between?(cultura.umidade_min, cultura.umidade_max)
      confianca = 85.0
      confianca += 5.0 if temp_ok
      confianca += 4.5 if umid_ok
      confianca = [confianca, 99.0].min

      rec = lote.recomendacao_colheitas.find_or_initialize_by(status: "PENDENTE")
      rec.data_inicio = inicio
      rec.data_fim = fim
      rec.grau_confianca = confianca.round(2)
      rec.data_atualizacao = Time.current
      rec.save!
    end
  end
end
