class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy]
  before_action :admin_authorized, only: %i[ index update destroy]
  skip_before_action :authorized, only: [ :create ]

  # GET: '/api/v1/users'
  def index
    users = User.where(role: 'client')
    render json: users
  end

  # POST: '/api/v1/users'
  def create
    @user = User.new(user_params)
    if @user.save
      token = encode_token({ user_id: @user.id })
      render json: { user: @user, token: token }, status: :created
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # GET: '/api/v1/users/:id'
  def show
    render json: @user
  end

  # PATCH: '/api/v1/users/:id'
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  # DELETE: '/api/v1/users/:id'
  def destroy
    if @user.destroy
      render json: { message: 'User deleted' }, status: :ok
    else
      render json: { errors: @user.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find_by(id: params[:id])
    if @user.nil?
      render json: { message: 'User not found' }, status: :not_found
    end
  end

  def user_params
    params.require(:user).permit(:email, :password, :name, :role)
  end
end
