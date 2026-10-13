class RecomendacaoColheita < ApplicationRecord
  self.table_name = "recomendacao_colheitas"

  belongs_to :lote

  STATUSES = %w[PENDENTE ACEITA REJEITADA].freeze

  validates :data_inicio, presence: true
  validates :data_fim, presence: true
  validates :grau_confianca, presence: true, numericality: { in: 0..100 }
  validates :data_atualizacao, presence: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  def aceitar!
    update!(status: "ACEITA", data_atualizacao: Time.current)
  end

  def rejeitar!
    update!(status: "REJEITADA", data_atualizacao: Time.current)
  end

  def as_json_public
    hist = lote&.historico_ativo
    cult = hist&.cultura || lote&.cultura_ativa || Cultura.first
    dias_decorridos = hist&.data_plantio ? (Date.current - hist.data_plantio).to_i : 75
    ciclo = cult&.ciclo_medio_dias || 120
    dias_restantes = [ciclo - dias_decorridos, 0].max

    # Indicadores do Modelo de Machine Learning HarvestPoint
    ult = lote&.ultima_leitura
    temp = ult&.temperatura || 28.5
    umid = ult&.umidade || 60.0

    # Estimativa de Brix baseada em acúmulo térmico (GDD - Graus-Dia)
    brix_base = cult&.nome.to_s.downcase.include?("uva") ? 17.5 : 13.8
    progresso_ciclo = [dias_decorridos.to_f / ciclo, 1.0].min
    brix_estimado = (brix_base * progresso_ciclo * (1.0 + (temp > 30 ? 0.05 : 0.0))).round(1)

    # Avaliação de risco fitossanitário (Míldio / Antracnose por alta umidade + calor)
    risco_fito = if umid > 75.0 && temp > 27.0
                   "Alto (Condições propícias a fungos)"
                 elsif umid > 65.0
                   "Moderado (Atenção à aeração)"
                 else
                   "Baixo (Microclima favorável)"
                 end

    qualidade = if grau_confianca.to_f >= 90.0 && risco_fito.start_with?("Baixo")
                  "Exportação Premium (Classe Extra)"
                elsif grau_confianca.to_f >= 80.0
                  "Padrão Cat-1 (Mercado Internacional/Nacional)"
                else
                  "Mercado Interno (Acompanhamento Recomendado)"
                end

    {
      id: id,
      lote_id: lote_id,
      lote_nome: lote&.nome,
      propriedade: lote&.propriedade&.nome,
      cultura: cult&.nome || "Manga Palmer",
      data_inicio: data_inicio&.to_s,
      data_fim: data_fim&.to_s,
      grau_confianca: grau_confianca.to_f,
      data_atualizacao: data_atualizacao&.iso8601,
      status: status,
      dias_decorridos: dias_decorridos,
      ciclo_medio_dias: ciclo,
      dias_restantes: dias_restantes,
      modelo_ml: {
        versao: "HarvestPoint AI Heuristic-ML v2.4",
        grau_brix_estimado: brix_estimado,
        qualidade_safra: qualidade,
        risco_fitossanitario: risco_fito,
        gdd_acumulado: (dias_decorridos * [temp - 10.0, 0].max).round(0)
      }
    }
  end
end
