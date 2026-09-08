# Be sure to restart your server when you modify this file.

# Origens vêm de CORS_ORIGINS (vírgula). Em desenvolvimento, aceita qualquer origem
# para facilitar o React PWA local. Em produção, defina CORS_ORIGINS explicitamente.

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins do |origin, _env|
      allowed = ENV.fetch("CORS_ORIGINS", "").split(",").map(&:strip).reject(&:blank?)

      if allowed.any?
        allowed.include?(origin)
      else
        Rails.env.development? || Rails.env.test?
      end
    end

    resource "*",
      headers: :any,
      methods: %i[get post put patch delete options head],
      expose: %w[Authorization]
  end
end
