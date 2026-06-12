class JwtService
  SECRET = ENV.fetch("JWT_SECRET", Rails.application.secret_key_base)
  ALGORITHM = "HS256"
  TTL = 24.hours

  def self.encode(payload)
    exp = Time.current.to_i + TTL.to_i
    JWT.encode(payload.merge("exp" => exp), SECRET, ALGORITHM)
  end

  def self.decode(token)
    decoded = JWT.decode(token, SECRET, true, { algorithm: ALGORITHM })
    decoded.first
  rescue JWT::DecodeError
    nil
  end
end
