# frozen_string_literal: true

class CreateProdutores < ActiveRecord::Migration[8.1]
  def change
    create_table :produtores do |t|
      t.string :nome_razao_social, null: false
      t.string :cpf_cnpj, null: false
      t.string :telefone
      t.string :email
      t.string :cidade
      t.string :estado, limit: 2
      t.string :responsavel

      t.timestamps
    end

    add_index :produtores, :cpf_cnpj, unique: true
  end
end
