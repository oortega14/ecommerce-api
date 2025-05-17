class Api::V1::SessionsController < ApplicationController
  skip_before_action :authorized, only: [ :create ]
  skip_before_action :admin_authorized, only: [ :create, :destroy ]

  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  def destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end
