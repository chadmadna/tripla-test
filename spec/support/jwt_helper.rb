module JwtHelper
  def generate_jwt_token(user)
    payload = { user_id: user.id }
    secret = Rails.application.credentials.secret_key_base || 'your_secret_key'
    JWT.encode(payload, secret, 'HS256')
  end
end
