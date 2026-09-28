class CreateLotes < ActiveRecord::Migration[8.1]
  def change
    create_table :lotes do |t|
      t.references :propriedade, null: false, foreign_key: true
      t.references :cultura, null: false, foreign_key: true
      t.string :nome
      t.decimal :area
      t.decimal :latitude
      t.decimal :longitude
      t.date :data_plantio

      t.timestamps
    end
  end
end
