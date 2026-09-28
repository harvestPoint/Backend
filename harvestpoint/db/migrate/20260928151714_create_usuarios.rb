class CreateUsuarios < ActiveRecord::Migration[8.1]
  def change
    create_table :usuarios do |t|
      t.string :nome
      t.string :email
      t.string :senha_hash
      t.string :cpf_cnpj
      t.string :telefone
      t.string :tipo_usuario
      t.datetime :data_cadastro

      t.timestamps
    end
  end
end
