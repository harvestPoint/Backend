class CreateSensors < ActiveRecord::Migration[8.1]
  def change
    create_table :sensors do |t|
      t.references :lote, null: false, foreign_key: true
      t.string :tipo
      t.string :unidade_medida
      t.string :status
      t.date :data_instalacao

      t.timestamps
    end
  end
end
