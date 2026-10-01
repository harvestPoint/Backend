# Be sure to restart your server when you modify this file.

# Add new inflection rules using the following format. Inflections
# are locale specific, and you may define rules for as many different
# locales as you wish. All of these examples are active by default:
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.irregular "sensor", "sensores"
  inflect.irregular "regiao", "regioes"
  inflect.irregular "clima_regiao", "clima_regioes"
  inflect.irregular "leitura_sensor", "leitura_sensores"
  inflect.irregular "recomendacao_colheita", "recomendacao_colheitas"
  inflect.irregular "preco_mercado", "preco_mercados"
  inflect.irregular "historico_cultivo", "historico_cultivos"
end

# These inflection rules are supported but not enabled by default:
# ActiveSupport::Inflector.inflections(:en) do |inflect|
#   inflect.acronym "RESTful"
# end
