# Be sure to restart your server when you modify this file.

# CORS: o Vite em desenvolvimento faz proxy de `/api` para esta API, então o
# navegador fala com a origem do frontend. Esta configuração cobre chamadas
# diretas ao Rails e o frontend em localhost:5173/4173 caso o proxy não seja usado.
#
# Em produção, defina FRONTEND_ORIGINS com as origens reais (lista separada por
# vírgula). Sem essa variável, nenhuma origem extra é liberada — não usamos `*`.

frontend_origins = ENV.fetch("FRONTEND_ORIGINS", "").split(",").map(&:strip).reject(&:blank?)

allowed_origins =
  if Rails.env.production?
    frontend_origins
  else
    %w[
      http://localhost:5173
      http://127.0.0.1:5173
      http://localhost:4173
      http://127.0.0.1:4173
    ] + frontend_origins
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
