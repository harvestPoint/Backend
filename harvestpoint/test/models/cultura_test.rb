require "test_helper"

class CulturaTest < ActiveSupport::TestCase
  test "desvio identifica acima, abaixo e dentro da faixa" do
    cultura = Cultura.create!(nome: "Manga", variedade: "Espada",
                               temperatura_min: 22, temperatura_max: 30, ciclo_dias: 120)

    assert_equal "acima", cultura.desvio("temperatura", 31.9)
    assert_equal "abaixo", cultura.desvio("temperatura", 18)
    assert_nil cultura.desvio("temperatura", 25)
  end

  test "max nao pode ser menor que o min" do
    cultura = Cultura.new(nome: "Uva", variedade: "Teste", temperatura_min: 30, temperatura_max: 20, ciclo_dias: 100)

    assert_not cultura.valid?
    assert_includes cultura.errors[:temperatura_max], "deve ser maior ou igual ao mínimo"
  end
end
