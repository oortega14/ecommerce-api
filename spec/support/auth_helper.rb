module AuthHelper
  def token_for(user)
    JWT.encode({ user_id: user.id }, jwt_secret_key)
  end

  def auth_headers(user)
    {
      'Authorization' => "Bearer #{token_for(user)}",
      'Accept' => 'application/json'
    }
  end

  private

  def jwt_secret_key
    Rails.application.credentials.jwt[:secret_key]
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
