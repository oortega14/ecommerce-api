class Api::V1::UsersController < ApplicationController
  skip_before_action :authorized, only: [ :create ]
  skip_before_action :admin_authorized, only: [ :create, :show, :update ]

  def create
    @user = User.new(user_params)
    if @user.save
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def show
    render json: current_user
  end

  def update
    if current_user.update(user_params)
      render json: current_user
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :name, :role)
  end
end
