class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :nome, null: false
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :role, null: false, default: "proprietario"
      t.string :propriedade, null: false
      t.string :api_token_digest

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :api_token_digest, unique: true, where: "api_token_digest IS NOT NULL"
  end
end
