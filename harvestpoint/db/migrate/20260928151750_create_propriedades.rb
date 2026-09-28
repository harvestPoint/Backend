class CreatePropriedades < ActiveRecord::Migration[8.1]
  def change
    create_table :propriedades do |t|
      t.references :usuario, null: false, foreign_key: true
      t.string :nome
      t.string :municipio
      t.string :localizacao
      t.decimal :area_total

      t.timestamps
    end
  end
end
