class CreateCulturas < ActiveRecord::Migration[8.1]
  def change
    create_table :culturas do |t|
      t.string :nome
      t.text :descricao
      t.integer :ciclo_medio_dias
      t.decimal :temperatura_min
      t.decimal :temperatura_max
      t.decimal :umidade_min
      t.decimal :umidade_max

      t.timestamps
    end
  end
end
