class ApplicationController < ActionController::API
  include JsonapiResponses::Respondable
  # Rescue From
  rescue_from ApiExceptions::BaseException, with: :render_error_response

  before_action :set_audited_user

  def render_error_response(error)
    error_response = {
      error: {
        code: error.code,
        messages: error.messages
      }
    }

    status_code = case error.error_type
    when :UNAUTHORIZED
      :unauthorized
    when :RECORD_NOT_FOUND
      :not_found
    when :ADMIN_AUTHORIZATION
      :forbidden
    else
      :unprocessable_entity
    end

    render json: error_response, status: status_code
  end

  def set_locale
    I18n.locale = params[:locale] || 'es'
  end

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
      @current_user = User.find_by(id: user_id)
    end
  end

  def authenticate_user
    unless !!current_user
      render_error_response(ApiExceptions::BaseException.new(:UNAUTHORIZED, [], {}))
    end
  end

  def authenticate_admin
    unless !!current_user && current_user.admin?
      render_error_response(ApiExceptions::BaseException.new(:ADMIN_AUTHORIZATION, [], {}))
    end
  end

  private

  def jwt_secret_key
    Rails.application.credentials.jwt[:secret_key]
  end

  def set_audited_user
    Audited.store[:audited_user] = current_user if current_user
  end
end
