class JsonWebToken
  class << self
    def encode(payload, exp = 24.hours.from_now)
      body = payload.dup
      body[:exp] = exp.to_i
      JWT.encode(body, secret_key, "HS256")
    end

    def decode(token)
      return if token.blank?

      decoded = JWT.decode(token, secret_key, true, { algorithm: "HS256" })[0]
      decoded.with_indifferent_access
    end

    private

    def secret_key
      ENV["JWT_SECRET_KEY"].presence || Rails.application.secret_key_base
    end
  end
end
