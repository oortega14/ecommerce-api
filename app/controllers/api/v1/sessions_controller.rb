class Api::V1::SessionsController < ApplicationController
  before_action :authenticate_user, only: [ :destroy ]

  # POST: '/api/v1/sessions'
  def create
    @user = User.find_by(email: params[:user][:email])
    if @user && @user.authenticate(params[:user][:password])
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # DELETE: '/api/v1/sessions'
  def destroy
    render json: { message: 'Logged out successfully' }, status: :ok
  end
end
