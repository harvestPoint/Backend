module ComexStatService
  class << self
    def dados_exportacao
      [
        {
          produto: "Manga",
          ncm: "08045020",
          media_por_mes: [
            { mes: 1, nome: "Jan", kg_medio: 4500000 },
            { mes: 2, nome: "Fev", kg_medio: 3800000 },
            { mes: 3, nome: "Mar", kg_medio: 4100000 },
            { mes: 4, nome: "Abr", kg_medio: 5200000 },
            { mes: 5, nome: "Mai", kg_medio: 6800000 },
            { mes: 6, nome: "Jun", kg_medio: 8900000 },
            { mes: 7, nome: "Jul", kg_medio: 12500000 },
            { mes: 8, nome: "Ago", kg_medio: 24000000 },
            { mes: 9, nome: "Set", kg_medio: 42500000 },
            { mes: 10, nome: "Out", kg_medio: 51200000 },
            { mes: 11, nome: "Nov", kg_medio: 44800000 },
            { mes: 12, nome: "Dez", kg_medio: 21500000 }
          ],
          meses_pico: [8, 9, 10, 11],
          top_destinos: [
            { pais: "Países Baixos", kg: 112000000, fob_usd: 128800000, participacao: 43.6 },
            { pais: "Estados Unidos", kg: 68000000, fob_usd: 78200000, participacao: 26.5 },
            { pais: "Reino Unido", kg: 34000000, fob_usd: 39100000, participacao: 13.2 },
            { pais: "Espanha", kg: 21000000, fob_usd: 24150000, participacao: 8.2 },
            { pais: "Portugal", kg: 12000000, fob_usd: 13800000, participacao: 4.7 }
          ],
          total_kg_12m: 229800000,
          total_fob_usd_12m: 264270000,
          preco_medio_usd_kg: 1.15,
          fonte: "cache",
          atualizado_em: Time.current.iso8601
        },
        {
          produto: "Uva",
          ncm: "08061000",
          media_por_mes: [
            { mes: 1, nome: "Jan", kg_medio: 1800000 },
            { mes: 2, nome: "Fev", kg_medio: 1200000 },
            { mes: 3, nome: "Mar", kg_medio: 2100000 },
            { mes: 4, nome: "Abr", kg_medio: 4900000 },
            { mes: 5, nome: "Mai", kg_medio: 6400000 },
            { mes: 6, nome: "Jun", kg_medio: 5100000 },
            { mes: 7, nome: "Jul", kg_medio: 2300000 },
            { mes: 8, nome: "Ago", kg_medio: 3200000 },
            { mes: 9, nome: "Set", kg_medio: 8900000 },
            { mes: 10, nome: "Out", kg_medio: 19800000 },
            { mes: 11, nome: "Nov", kg_medio: 22400000 },
            { mes: 12, nome: "Dez", kg_medio: 11500000 }
          ],
          meses_pico: [4, 5, 10, 11],
          top_destinos: [
            { pais: "Países Baixos", kg: 39500000, fob_usd: 86900000, participacao: 44.1 },
            { pais: "Reino Unido", kg: 24200000, fob_usd: 53240000, participacao: 27.0 },
            { pais: "Estados Unidos", kg: 13400000, fob_usd: 29480000, participacao: 15.0 },
            { pais: "Alemanha", kg: 6100000, fob_usd: 13420000, participacao: 6.8 },
            { pais: "Argentina", kg: 3200000, fob_usd: 7040000, participacao: 3.6 }
          ],
          total_kg_12m: 89600000,
          total_fob_usd_12m: 197120000,
          preco_medio_usd_kg: 2.20,
          fonte: "cache",
          atualizado_em: Time.current.iso8601
        }
      ]
    end

    def dados_logistica
      [
        {
          produto: "Manga",
          ncm: "08045020",
          periodo: { from: (Date.current - 24.months).strftime("%Y-%m"), to: Date.current.strftime("%Y-%m") },
          total_kg: 459600000,
          modais: [
            { nome: "Marítimo (Contêiner Refrigerado)", kg: 395256000, fob_usd: 454544400, participacao: 86.0 },
            { nome: "Aéreo (Frutas Premium / Cargas Rápidas)", kg: 50556000, fob_usd: 68250600, participacao: 11.0 },
            { nome: "Rodoviário (Mercosul)", kg: 13788000, fob_usd: 15856200, participacao: 3.0 }
          ],
          saidas: [
            { nome: "Porto de Suape (Ipojuca - PE)", kg: 266568000, fob_usd: 306553200, participacao: 58.0 },
            { nome: "Porto de Salvador (Salvador - BA)", kg: 119496000, fob_usd: 137420400, participacao: 26.0 },
            { nome: "Aeroporto Senador Nilo Coelho (Petrolina - PE)", kg: 45960000, fob_usd: 62046000, participacao: 10.0 },
            { nome: "Porto de Pecém / Santos", kg: 27576000, fob_usd: 31712400, participacao: 6.0 }
          ],
          fonte: "cache",
          atualizado_em: Time.current.iso8601
        },
        {
          produto: "Uva",
          ncm: "08061000",
          periodo: { from: (Date.current - 24.months).strftime("%Y-%m"), to: Date.current.strftime("%Y-%m") },
          total_kg: 179200000,
          modais: [
            { nome: "Marítimo (Contêiner Reefers)", kg: 157696000, fob_usd: 346931200, participacao: 88.0 },
            { nome: "Aéreo (Aeroporto PNZ / VCP)", kg: 16128000, fob_usd: 40320000, participacao: 9.0 },
            { nome: "Rodoviário (Mercosul)", kg: 5376000, fob_usd: 11827200, participacao: 3.0 }
          ],
          saidas: [
            { nome: "Porto de Suape (Ipojuca - PE)", kg: 111104000, fob_usd: 244428800, participacao: 62.0 },
            { nome: "Porto de Salvador (Salvador - BA)", kg: 41216000, fob_usd: 90675200, participacao: 23.0 },
            { nome: "Aeroporto Senador Nilo Coelho (Petrolina - PE)", kg: 16128000, fob_usd: 40320000, participacao: 9.0 },
            { nome: "Outros portos", kg: 10752000, fob_usd: 23654400, participacao: 6.0 }
          ],
          fonte: "cache",
          atualizado_em: Time.current.iso8601
        }
      ]
    end
  end
end
