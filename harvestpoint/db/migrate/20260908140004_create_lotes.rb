# frozen_string_literal: true

class CreateLotes < ActiveRecord::Migration[8.1]
  def change
    create_table :lotes do |t|
      t.references :propriedade, null: false, foreign_key: true
      t.references :cultura, null: false, foreign_key: true
      t.string :nome, null: false
      t.decimal :area, precision: 12, scale: 2
      t.date :data_plantio
      t.date :previsao_colheita
      t.string :situacao, null: false, default: "ativo"

      t.timestamps
    end
  end
end
