class CreateAlerta < ActiveRecord::Migration[8.1]
  def change
    create_table :alerta do |t|
      t.references :lote, null: false, foreign_key: true
      t.references :sensor, null: false, foreign_key: true
      t.string :tipo_alerta
      t.text :mensagem
      t.datetime :data_hora
      t.boolean :resolvido

      t.timestamps
    end
  end
end
