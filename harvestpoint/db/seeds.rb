# Catálogo de culturas — usado pela tela "Culturas" e pelo AlertaGerador para
# saber a faixa ideal de cada (cultura, variedade). Idempotente.
[
  { nome: "Manga", variedade: "Espada",
    temperatura_min: 22, temperatura_max: 30, umidade_ar_min: 60, umidade_ar_max: 80,
    umidade_solo_min: 50, umidade_solo_max: 70, ciclo_dias: 120 },
  { nome: "Uva", variedade: "Núbia",
    temperatura_min: 20, temperatura_max: 28, umidade_ar_min: 55, umidade_ar_max: 70,
    umidade_solo_min: 45, umidade_solo_max: 65, ciclo_dias: 150 },
  { nome: "Uva", variedade: "Autumn Crisp",
    temperatura_min: 21, temperatura_max: 29, umidade_ar_min: 58, umidade_ar_max: 72,
    umidade_solo_min: 45, umidade_solo_max: 65, ciclo_dias: 145 },
  { nome: "Uva", variedade: "Aragonez",
    temperatura_min: 18, temperatura_max: 28, umidade_ar_min: 50, umidade_ar_max: 65,
    umidade_solo_min: 40, umidade_solo_max: 60, ciclo_dias: 150 },
  { nome: "Uva", variedade: "Cabernet Sauvignon",
    temperatura_min: 18, temperatura_max: 29, umidade_ar_min: 50, umidade_ar_max: 65,
    umidade_solo_min: 40, umidade_solo_max: 60, ciclo_dias: 160 }
].each do |atributos|
  Cultura.find_or_create_by!(nome: atributos[:nome], variedade: atributos[:variedade]) do |cultura|
    cultura.assign_attributes(atributos)
  end
end

puts "Seeds ok — #{Cultura.count} culturas cadastradas."
