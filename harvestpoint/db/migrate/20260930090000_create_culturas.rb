class CreateCulturas < ActiveRecord::Migration[8.1]
  def change
    create_table :culturas do |t|
      t.string :nome, null: false
      t.string :variedade, null: false
      t.decimal :temperatura_min, precision: 5, scale: 2
      t.decimal :temperatura_max, precision: 5, scale: 2
      t.decimal :umidade_ar_min, precision: 5, scale: 2
      t.decimal :umidade_ar_max, precision: 5, scale: 2
      t.decimal :umidade_solo_min, precision: 5, scale: 2
      t.decimal :umidade_solo_max, precision: 5, scale: 2
      t.integer :ciclo_dias, null: false

      t.timestamps
    end

    add_index :culturas, [ :nome, :variedade ], unique: true
  end
end
