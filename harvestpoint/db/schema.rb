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

ActiveRecord::Schema[8.1].define(version: 2026_09_30_090003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alertas", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lote_id"
    t.bigint "sensor_id"
    t.bigint "leitura_id"
    t.string "severidade", null: false
    t.string "status", default: "aberto", null: false
    t.string "titulo", null: false
    t.string "grandeza"
    t.string "direcao"
    t.decimal "valor", precision: 8, scale: 2
    t.decimal "limite", precision: 8, scale: 2
    t.datetime "resolvido_em"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["leitura_id"], name: "index_alertas_on_leitura_id"
    t.index ["lote_id", "sensor_id", "grandeza", "status"], name: "index_alertas_em_aberto"
    t.index ["lote_id"], name: "index_alertas_on_lote_id"
    t.index ["sensor_id"], name: "index_alertas_on_sensor_id"
    t.index ["status"], name: "index_alertas_on_status"
    t.index ["user_id"], name: "index_alertas_on_user_id"
  end

  create_table "culturas", force: :cascade do |t|
    t.string "nome", null: false
    t.string "variedade", null: false
    t.decimal "temperatura_min", precision: 5, scale: 2
    t.decimal "temperatura_max", precision: 5, scale: 2
    t.decimal "umidade_ar_min", precision: 5, scale: 2
    t.decimal "umidade_ar_max", precision: 5, scale: 2
    t.decimal "umidade_solo_min", precision: 5, scale: 2
    t.decimal "umidade_solo_max", precision: 5, scale: 2
    t.integer "ciclo_dias", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["nome", "variedade"], name: "index_culturas_on_nome_and_variedade", unique: true
  end

  create_table "leituras", force: :cascade do |t|
    t.bigint "sensor_id", null: false
    t.bigint "lote_id"
    t.datetime "medido_em", null: false
    t.decimal "temperatura", precision: 5, scale: 2
    t.decimal "umidade_ar", precision: 5, scale: 2
    t.decimal "umidade_solo", precision: 5, scale: 2
    t.decimal "precipitacao", precision: 6, scale: 2
    t.string "origem", default: "sensor", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lote_id", "medido_em"], name: "index_leituras_on_lote_id_and_medido_em"
    t.index ["lote_id"], name: "index_leituras_on_lote_id"
    t.index ["sensor_id", "medido_em"], name: "index_leituras_on_sensor_id_and_medido_em"
    t.index ["sensor_id"], name: "index_leituras_on_sensor_id"
  end

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

  create_table "sensores", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "lote_id"
    t.string "codigo", null: false
    t.string "grandezas", default: [], null: false, array: true
    t.date "instalado_em"
    t.datetime "ultima_leitura_em"
    t.string "token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["lote_id"], name: "index_sensores_on_lote_id"
    t.index ["token"], name: "index_sensores_on_token", unique: true
    t.index ["user_id", "codigo"], name: "index_sensores_on_user_id_and_codigo", unique: true
    t.index ["user_id"], name: "index_sensores_on_user_id"
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

  add_foreign_key "alertas", "leituras"
  add_foreign_key "alertas", "lotes"
  add_foreign_key "alertas", "sensores"
  add_foreign_key "alertas", "users"
  add_foreign_key "leituras", "lotes"
  add_foreign_key "leituras", "sensores"
  add_foreign_key "lotes", "users"
  add_foreign_key "sensores", "lotes"
  add_foreign_key "sensores", "users"
end
