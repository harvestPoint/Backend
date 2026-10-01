class CreateLotes < ActiveRecord::Migration[8.1]
  def change
    create_table :lotes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :codigo, null: false
      t.string :propriedade, null: false
      t.string :cultura, null: false
      t.string :variedade, null: false
      t.decimal :area_ha, precision: 10, scale: 2, null: false
      t.date :data_plantio
      t.string :sensor_vinculado
      t.string :status, null: false, default: "ativo"

      t.timestamps
    end

    add_index :lotes, [ :user_id, :codigo ], unique: true
  end
end
