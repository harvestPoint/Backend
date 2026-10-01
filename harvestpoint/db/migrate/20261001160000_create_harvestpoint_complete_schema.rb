class CreateHarvestpointCompleteSchema < ActiveRecord::Migration[8.1]
  def change
    # Limpa estruturas embrionárias anteriores se existirem
    drop_table :lotes, if_exists: true, cascade: true
    drop_table :users, if_exists: true, cascade: true

    # 1. USUARIO (Central de Acessos)
    create_table :usuarios do |t|
      t.string :nome, limit: 150, null: false
      t.string :email, limit: 150, null: false
      t.string :senha_hash, limit: 255, null: false
      t.string :cpf_cnpj, limit: 20, null: false
      t.string :telefone, limit: 20, null: false
      t.string :tipo_usuario, limit: 20, null: false # 'PRODUTOR' ou 'TECNICO'
      t.datetime :data_cadastro, null: false, default: -> { "CURRENT_TIMESTAMP" }
      t.string :api_token_digest, limit: 255

      t.timestamps
    end
    add_index :usuarios, :email, unique: true
    add_index :usuarios, :cpf_cnpj, unique: true
    add_index :usuarios, :api_token_digest, unique: true, where: "api_token_digest IS NOT NULL"

    # 2. PROPRIEDADE (Locais de Cultivo)
    create_table :propriedades do |t|
      t.references :usuario, null: false, foreign_key: { to_table: :usuarios }
      t.string :nome, limit: 150, null: false
      t.string :municipio, limit: 100, null: false
      t.decimal :latitude, precision: 10, scale: 8, null: false
      t.decimal :longitude, precision: 10, scale: 8, null: false
      t.decimal :area_total, precision: 10, scale: 2, null: false

      t.timestamps
    end

    # 3. CULTURA (Base de Conhecimento Agrícola para a IA)
    create_table :culturas do |t|
      t.string :nome, limit: 100, null: false
      t.integer :ciclo_medio_dias, null: false
      t.decimal :temperatura_min, precision: 5, scale: 2, null: false
      t.decimal :temperatura_max, precision: 5, scale: 2, null: false
      t.decimal :umidade_min, precision: 5, scale: 2, null: false
      t.decimal :umidade_max, precision: 5, scale: 2, null: false

      t.timestamps
    end

    # 4. LOTE (Áreas Específicas Monitoradas)
    create_table :lotes do |t|
      t.references :propriedade, null: false, foreign_key: { to_table: :propriedades }
      t.string :nome, limit: 100, null: false
      t.decimal :area, precision: 10, scale: 2, null: false

      t.timestamps
    end

    # 5. HISTORICO_CULTIVO (Vínculo Temporal entre Lote e Cultura)
    create_table :historico_cultivos do |t|
      t.references :lote, null: false, foreign_key: { to_table: :lotes }
      t.references :cultura, null: false, foreign_key: { to_table: :culturas }
      t.date :data_plantio, null: false
      t.date :data_fim_ciclo
      t.string :status, limit: 20, null: false # 'ATIVO', 'FINALIZADO'

      t.timestamps
    end

    # 6. PRECO_MERCADO (Cotações para a Inteligência Artificial)
    create_table :preco_mercados do |t|
      t.references :cultura, null: false, foreign_key: { to_table: :culturas }
      t.decimal :preco_medio, precision: 10, scale: 2, null: false
      t.string :moeda, limit: 3, null: false # 'BRL', 'USD'
      t.date :data_cotacao, null: false

      t.timestamps
    end

    # 7. CLIMA_REGIAO (Macroclima da Propriedade)
    create_table :clima_regioes do |t|
      t.references :propriedade, null: false, foreign_key: { to_table: :propriedades }
      t.date :data_previsao, null: false
      t.decimal :temperatura_min, precision: 5, scale: 2, null: false
      t.decimal :temperatura_max, precision: 5, scale: 2, null: false
      t.decimal :chance_chuva_percentual, precision: 5, scale: 2, null: false
      t.decimal :precipitacao_mm, precision: 5, scale: 2

      t.timestamps
    end

    # 8. SENSOR (Dispositivos IoT no Campo)
    create_table :sensores do |t|
      t.references :lote, null: false, foreign_key: { to_table: :lotes }
      t.string :codigo, limit: 50, null: false # MAC Address
      t.string :status, limit: 20, null: false # 'ATIVO', 'INATIVO', 'MANUTENCAO'

      t.timestamps
    end
    add_index :sensores, :codigo, unique: true

    # 9. LEITURA_SENSOR (Série Temporal de Clima / Microclima IoT)
    create_table :leitura_sensores do |t|
      t.references :sensor, null: false, foreign_key: { to_table: :sensores }
      t.datetime :data_hora, null: false
      t.decimal :temperatura, precision: 5, scale: 2, null: false
      t.decimal :umidade, precision: 5, scale: 2, null: false

      t.timestamps
    end
    add_index :leitura_sensores, [ :sensor_id, :data_hora ]

    # 10. ALERTA (Regras de Negócio e Desvios)
    create_table :alertas do |t|
      t.references :sensor, null: false, foreign_key: { to_table: :sensores }
      t.string :tipo, limit: 50, null: false
      t.text :mensagem, null: false
      t.datetime :data_hora, null: false
      t.boolean :resolvido, null: false, default: false

      t.timestamps
    end
    add_index :alertas, [ :sensor_id, :resolvido ]

    # 11. RECOMENDACAO_COLHEITA (Saída da IA e Interação Humana)
    create_table :recomendacao_colheitas do |t|
      t.references :lote, null: false, foreign_key: { to_table: :lotes }
      t.date :data_inicio, null: false
      t.date :data_fim, null: false
      t.decimal :grau_confianca, precision: 5, scale: 2, null: false
      t.datetime :data_atualizacao, null: false
      t.string :status, limit: 20, null: false # 'PENDENTE', 'ACEITA', 'REJEITADA'

      t.timestamps
    end
    add_index :recomendacao_colheitas, [ :lote_id, :status ]
  end
end
