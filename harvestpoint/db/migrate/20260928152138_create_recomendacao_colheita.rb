class CreateRecomendacaoColheita < ActiveRecord::Migration[8.1]
  def change
    create_table :recomendacao_colheita do |t|
      t.references :lote, null: false, foreign_key: true
      t.date :data_recomendacao
      t.decimal :expectativa_produtividade
      t.text :observacoes
      t.string :status

      t.timestamps
    end
  end
end
