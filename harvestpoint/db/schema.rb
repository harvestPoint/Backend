# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_09_28_120001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "lotes", force: :cascade do |t|
    t.decimal "area_ha", precision: 10, scale: 2, null: false
    t.string "codigo", null: false
    t.datetime "created_at", null: false
    t.string "cultura", null: false
    t.date "data_plantio"
    t.string "propriedade", null: false
    t.string "sensor_vinculado"
    t.string "status", default: "ativo", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "variedade", null: false
    t.index ["user_id", "codigo"], name: "index_lotes_on_user_id_and_codigo", unique: true
    t.index ["user_id"], name: "index_lotes_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "api_token_digest"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "nome", null: false
    t.string "password_digest", null: false
    t.string "propriedade", null: false
    t.string "role", default: "proprietario", null: false
    t.datetime "updated_at", null: false
    t.index ["api_token_digest"], name: "index_users_on_api_token_digest", unique: true, where: "(api_token_digest IS NOT NULL)"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "lotes", "users"
end
