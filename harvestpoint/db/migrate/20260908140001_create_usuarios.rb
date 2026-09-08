# frozen_string_literal: true

class CreateUsuarios < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      t.string :nome, null: false
      t.string :cpf, null: false
      t.string :email, null: false
      t.string :telefone
      t.string :password_digest, null: false
      t.string :tipo_usuario, null: false, default: "produtor"
      t.string :status, null: false, default: "ativo"
      t.references :produtor, foreign_key: true, null: true

      t.timestamps
    end

    add_index :usuarios, :email, unique: true
    add_index :usuarios, :cpf, unique: true
  end
end
