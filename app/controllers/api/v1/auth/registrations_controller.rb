class Api::V1::Auth::RegistrationsController < ApplicationController
  # POST: '/api/v1/auth/sign_up'
  def create
    user = User.new(permitted_params)
    if user.save
      token = encode_token({ user_id: user.id })
      render json: { user: user, token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def permitted_params
    params.require(:user).permit(:email, :password, :name)
  end
end
