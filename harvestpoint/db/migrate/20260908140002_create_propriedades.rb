# frozen_string_literal: true

class CreatePropriedades < ActiveRecord::Migration[8.1]
  def change
    create_table :propriedades do |t|
      t.references :produtor, null: false, foreign_key: true
      t.string :nome, null: false
      t.string :municipio
      t.string :estado, limit: 2
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6
      t.decimal :area_total, precision: 12, scale: 2
      t.string :status, null: false, default: "ativo"

      t.timestamps
    end
  end
end
