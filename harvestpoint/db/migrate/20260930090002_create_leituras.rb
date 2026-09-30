class CreateLeituras < ActiveRecord::Migration[8.1]
  def change
    create_table :leituras do |t|
      t.references :sensor, null: false, foreign_key: { to_table: :sensores }
      t.references :lote, foreign_key: true
      t.datetime :medido_em, null: false
      t.decimal :temperatura, precision: 5, scale: 2
      t.decimal :umidade_ar, precision: 5, scale: 2
      t.decimal :umidade_solo, precision: 5, scale: 2
      t.decimal :precipitacao, precision: 6, scale: 2
      t.string :origem, null: false, default: "sensor"

      t.timestamps
    end

    add_index :leituras, [ :sensor_id, :medido_em ]
    add_index :leituras, [ :lote_id, :medido_em ]
  end
end
