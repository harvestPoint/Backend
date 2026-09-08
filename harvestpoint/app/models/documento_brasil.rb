# Validação de dígitos verificadores de CPF e CNPJ.
# Usada pelos models; não substitui consulta à Receita Federal.
module DocumentoBrasil
  module_function

  def cpf_valido?(valor)
    digits = somente_digitos(valor)
    return false unless digits.length == 11
    return false if digits.chars.uniq.length == 1

    verificadores_validos?(digits, [ 10, 9, 8, 7, 6, 5, 4, 3, 2 ], 9) &&
      verificadores_validos?(digits, [ 11, 10, 9, 8, 7, 6, 5, 4, 3, 2 ], 10)
  end

  def cnpj_valido?(valor)
    digits = somente_digitos(valor)
    return false unless digits.length == 14
    return false if digits.chars.uniq.length == 1

    verificadores_validos?(digits, [ 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ], 12) &&
      verificadores_validos?(digits, [ 6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2 ], 13)
  end

  def somente_digitos(valor)
    valor.to_s.gsub(/\D/, "")
  end

  def verificadores_validos?(digits, pesos, posicao)
    soma = pesos.each_with_index.sum { |peso, index| digits[index].to_i * peso }
    resto = soma % 11
    esperado = resto < 2 ? 0 : 11 - resto
    digits[posicao].to_i == esperado
  end
end
