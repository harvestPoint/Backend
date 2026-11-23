# Be sure to restart your server when you modify this file.

# CORS: o Vite em desenvolvimento faz proxy de `/api` para esta API, então o
# navegador fala com a origem do frontend. Esta configuração cobre chamadas
# diretas ao Rails e o frontend em localhost:5173/4173 caso o proxy não seja usado.
#
# Em produção, defina FRONTEND_ORIGINS com as origens reais (lista separada por vírgula).
# Ex: FRONTEND_ORIGINS="https://meuapp.com,https://painel.meuapp.com"
# Se não for informado, aceita "*" como fallback seguro para evitar falha no boot.

raw_origins = ENV.fetch("FRONTEND_ORIGINS", "").strip
frontend_origins = raw_origins.split(",").map(&:strip).reject(&:blank?)

allowed_origins =
  if Rails.env.production?
    frontend_origins.presence || ["*"]
  else
    default_dev = %w[
      http://localhost:5173
      http://127.0.0.1:5173
      http://localhost:4173
      http://127.0.0.1:4173
    ]
    (default_dev + frontend_origins).uniq
  end

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*allowed_origins)

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: [ "Authorization" ]
  end
end
