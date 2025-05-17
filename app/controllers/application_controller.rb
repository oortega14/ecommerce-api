class ApplicationController < ActionController::API
  # Before Actions
  before_action :authorized

  def encode_token(payload)
    JWT.encode(payload, jwt_secret_key)
  end

  def decoded_token
    header = request.headers['Authorization']
    if header
      token = header.split(' ')[1]
      begin
        JWT.decode(token, jwt_secret_key)
      rescue JWT::DecodeError
        nil
      end
    end
  end

  def current_user
    if decoded_token
      user_id = decoded_token[0]['user_id']
      @user = User.find_by(id: user_id)
    end
  end

  def authorized
    unless !!current_user
      render json: { message: 'Please log in' }, status: :unauthorized
    end
  end

  def admin_authorized
    unless !!current_user && current_user.admin?
      render json: { message: 'You are not authorized to perform this action' }, status: :forbidden
    end
  end

  private

  def jwt_secret_key
    Rails.application.credentials.jwt[:secret_key]
  end
end
