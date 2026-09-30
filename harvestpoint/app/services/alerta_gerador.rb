# Roda depois de cada leitura salva: compara com a faixa ideal da Cultura que
# corresponde ao (cultura, variedade) do lote e abre ou resolve alertas.
# Sem uma Cultura cadastrada com esse nome+variedade, não há faixa e nada é gerado.
class AlertaGerador
  MEDIDAS = {
    "temperatura" => { rotulo: "Temperatura", unidade: "°C", desvio_critico: 1.5 },
    "umidade_ar" => { rotulo: "Umidade do ar", unidade: "%", desvio_critico: 15.0 },
    "umidade_solo" => { rotulo: "Umidade do solo", unidade: "%", desvio_critico: 15.0 }
  }.freeze

  def initialize(leitura)
    @leitura = leitura
    @lote = leitura.lote
    @cultura = @lote && Cultura.para(@lote.cultura, @lote.variedade)
  end

  def call
    return if @cultura.nil?
    return if @leitura.medido_em < Leitura::JANELA_PARA_ALERTA.ago

    MEDIDAS.each_key { |medida| avaliar(medida) }
  end

  private

  def avaliar(medida)
    valor = @leitura[medida]
    faixa = @cultura.faixa(medida)
    return if valor.nil? || faixa.nil?

    direcao = @cultura.desvio(medida, valor)
    return resolver(abertos(medida)) if direcao.nil?

    resolver(abertos(medida).where.not(direcao: direcao)) # mudou de sentido (acima -> abaixo)
    return if abertos(medida).exists?(direcao: direcao)

    min, max = faixa
    limite = direcao == "acima" ? max : min
    Alerta.create!(
      user: @lote.user, lote: @lote, sensor: @leitura.sensor, leitura: @leitura,
      severidade: severidade(medida, valor, limite), status: "aberto",
      titulo: titulo(medida, direcao, valor, min, max),
      grandeza: medida, direcao: direcao, valor: valor, limite: limite
    )
  end

  def abertos(medida)
    Alerta.where(lote_id: @lote.id, sensor_id: @leitura.sensor_id, grandeza: medida, status: %w[aberto em_analise])
  end

  def resolver(relacao)
    agora = Time.current
    relacao.update_all(status: "resolvido", resolvido_em: agora, updated_at: agora)
  end

  def severidade(medida, valor, limite)
    (valor - limite).abs >= MEDIDAS.dig(medida, :desvio_critico) ? "critico" : "atencao"
  end

  def titulo(medida, direcao, valor, min, max)
    unidade = MEDIDAS.dig(medida, :unidade)
    if medida == "temperatura" && direcao == "acima"
      "Estresse térmico — #{fmt(valor)} #{unidade}, limite máximo de #{fmt(max)} #{unidade} (#{@cultura.nome})"
    elsif medida == "temperatura"
      "Temperatura abaixo do ideal — #{fmt(valor)} #{unidade}, mínimo de #{fmt(min)} #{unidade} (#{@cultura.nome})"
    else
      "#{MEDIDAS.dig(medida, :rotulo)} #{direcao} do ideal — #{fmt(valor)}%, faixa #{fmt(min)}–#{fmt(max)}%"
    end
  end

  def fmt(numero)
    return "?" if numero.nil?

    format("%.1f", numero).tr(".", ",")
  end
end
