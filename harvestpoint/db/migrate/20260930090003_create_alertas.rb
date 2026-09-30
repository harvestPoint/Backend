class CreateAlertas < ActiveRecord::Migration[8.1]
  def change
    create_table :alertas do |t|
      t.references :user, null: false, foreign_key: true
      t.references :lote, foreign_key: true
      t.references :sensor, foreign_key: { to_table: :sensores }
      t.references :leitura, foreign_key: true
      t.string :severidade, null: false
      t.string :status, null: false, default: "aberto"
      t.string :titulo, null: false
      t.string :grandeza
      t.string :direcao
      t.decimal :valor, precision: 8, scale: 2
      t.decimal :limite, precision: 8, scale: 2
      t.datetime :resolvido_em

      t.timestamps
    end

    add_index :alertas, :status
    add_index :alertas, [ :lote_id, :sensor_id, :grandeza, :status ], name: "index_alertas_em_aberto"
  end
end
