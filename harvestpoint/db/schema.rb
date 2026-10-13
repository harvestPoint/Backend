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

ActiveRecord::Schema[8.1].define(version: 2026_10_01_160000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "alertas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "data_hora", null: false
    t.text "mensagem", null: false
    t.boolean "resolvido", default: false, null: false
    t.bigint "sensor_id", null: false
    t.string "tipo", limit: 50, null: false
    t.datetime "updated_at", null: false
    t.index ["sensor_id", "resolvido"], name: "index_alertas_on_sensor_id_and_resolvido"
    t.index ["sensor_id"], name: "index_alertas_on_sensor_id"
  end

  create_table "clima_regioes", force: :cascade do |t|
    t.decimal "chance_chuva_percentual", precision: 5, scale: 2, null: false
    t.datetime "created_at", null: false
    t.date "data_previsao", null: false
    t.decimal "precipitacao_mm", precision: 5, scale: 2
    t.bigint "propriedade_id", null: false
    t.decimal "temperatura_max", precision: 5, scale: 2, null: false
    t.decimal "temperatura_min", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["propriedade_id"], name: "index_clima_regioes_on_propriedade_id"
  end

  create_table "culturas", force: :cascade do |t|
    t.integer "ciclo_medio_dias", null: false
    t.datetime "created_at", null: false
    t.string "nome", limit: 100, null: false
    t.decimal "temperatura_max", precision: 5, scale: 2, null: false
    t.decimal "temperatura_min", precision: 5, scale: 2, null: false
    t.decimal "umidade_max", precision: 5, scale: 2, null: false
    t.decimal "umidade_min", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
  end

  create_table "historico_cultivos", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "cultura_id", null: false
    t.date "data_fim_ciclo"
    t.date "data_plantio", null: false
    t.bigint "lote_id", null: false
    t.string "status", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["cultura_id"], name: "index_historico_cultivos_on_cultura_id"
    t.index ["lote_id"], name: "index_historico_cultivos_on_lote_id"
  end

  create_table "leitura_sensores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "data_hora", null: false
    t.bigint "sensor_id", null: false
    t.decimal "temperatura", precision: 5, scale: 2, null: false
    t.decimal "umidade", precision: 5, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["sensor_id", "data_hora"], name: "index_leitura_sensores_on_sensor_id_and_data_hora"
    t.index ["sensor_id"], name: "index_leitura_sensores_on_sensor_id"
  end

  create_table "lotes", force: :cascade do |t|
    t.decimal "area", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.string "nome", limit: 100, null: false
    t.bigint "propriedade_id", null: false
    t.datetime "updated_at", null: false
    t.index ["propriedade_id"], name: "index_lotes_on_propriedade_id"
  end

  create_table "preco_mercados", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "cultura_id", null: false
    t.date "data_cotacao", null: false
    t.string "moeda", limit: 3, null: false
    t.decimal "preco_medio", precision: 10, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["cultura_id"], name: "index_preco_mercados_on_cultura_id"
  end

  create_table "propriedades", force: :cascade do |t|
    t.decimal "area_total", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.decimal "latitude", precision: 10, scale: 8, null: false
    t.decimal "longitude", precision: 10, scale: 8, null: false
    t.string "municipio", limit: 100, null: false
    t.string "nome", limit: 150, null: false
    t.datetime "updated_at", null: false
    t.bigint "usuario_id", null: false
    t.index ["usuario_id"], name: "index_propriedades_on_usuario_id"
  end

  create_table "recomendacao_colheitas", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "data_atualizacao", null: false
    t.date "data_fim", null: false
    t.date "data_inicio", null: false
    t.decimal "grau_confianca", precision: 5, scale: 2, null: false
    t.bigint "lote_id", null: false
    t.string "status", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["lote_id", "status"], name: "index_recomendacao_colheitas_on_lote_id_and_status"
    t.index ["lote_id"], name: "index_recomendacao_colheitas_on_lote_id"
  end

  create_table "sensores", force: :cascade do |t|
    t.string "codigo", limit: 50, null: false
    t.datetime "created_at", null: false
    t.bigint "lote_id", null: false
    t.string "status", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["codigo"], name: "index_sensores_on_codigo", unique: true
    t.index ["lote_id"], name: "index_sensores_on_lote_id"
  end

  create_table "usuarios", force: :cascade do |t|
    t.string "api_token_digest", limit: 255
    t.string "cpf_cnpj", limit: 20, null: false
    t.datetime "created_at", null: false
    t.datetime "data_cadastro", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.string "email", limit: 150, null: false
    t.string "nome", limit: 150, null: false
    t.string "senha_hash", limit: 255, null: false
    t.string "telefone", limit: 20, null: false
    t.string "tipo_usuario", limit: 20, null: false
    t.datetime "updated_at", null: false
    t.index ["api_token_digest"], name: "index_usuarios_on_api_token_digest", unique: true, where: "(api_token_digest IS NOT NULL)"
    t.index ["cpf_cnpj"], name: "index_usuarios_on_cpf_cnpj", unique: true
    t.index ["email"], name: "index_usuarios_on_email", unique: true
  end

  add_foreign_key "alertas", "sensores"
  add_foreign_key "clima_regioes", "propriedades"
  add_foreign_key "historico_cultivos", "culturas"
  add_foreign_key "historico_cultivos", "lotes"
  add_foreign_key "leitura_sensores", "sensores"
  add_foreign_key "lotes", "propriedades"
  add_foreign_key "preco_mercados", "culturas"
  add_foreign_key "propriedades", "usuarios"
  add_foreign_key "recomendacao_colheitas", "lotes"
  add_foreign_key "sensores", "lotes"
end
