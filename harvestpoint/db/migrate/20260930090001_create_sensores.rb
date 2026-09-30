class CreateSensores < ActiveRecord::Migration[8.1]
  def change
    create_table :sensores do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lote, foreign_key: true
      t.string :codigo, null: false
      t.string :grandezas, array: true, null: false, default: []
      t.date :instalado_em
      t.datetime :ultima_leitura_em
      t.string :token, null: false

      t.timestamps
    end

    add_index :sensores, [ :user_id, :codigo ], unique: true
    add_index :sensores, :token, unique: true
  end
end
