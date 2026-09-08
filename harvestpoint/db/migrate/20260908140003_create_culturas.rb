# frozen_string_literal: true

class CreateCulturas < ActiveRecord::Migration[8.1]
  def change
    create_table :culturas do |t|
      t.string :nome, null: false
      t.string :variedade
      t.decimal :temperatura_min, precision: 5, scale: 2
      t.decimal :temperatura_max, precision: 5, scale: 2
      t.decimal :umidade_min, precision: 5, scale: 2
      t.decimal :umidade_max, precision: 5, scale: 2
      t.integer :ciclo_medio_dias
      t.text :descricao

      t.timestamps
    end
  end
end
