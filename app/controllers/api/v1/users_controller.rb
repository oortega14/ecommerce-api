class Api::V1::UsersController < ApplicationController
  before_action :set_user, only: %i[ show update destroy]
  before_action :authenticate_admin, only: %i[ index update destroy]
  before_action :authenticate_user, only: [ :show ]

  # GET: '/api/v1/users'
  def index
    users = User.where(role: 'client')
    render_with(users, context: { view: view_param })
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
    render_with(@user, context: { view: view_param })
  end

  # PATCH: '/api/v1/users/:id'
  def update
    @user.update(user_params)
    render_with(@user)
  end

  # DELETE: '/api/v1/users/:id'
  def destroy
    render_with(@user)
  end

  private

  def set_user
    @user = User.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ApiExceptions::BaseException.new(:RECORD_NOT_FOUND, [], {})
  end

  def user_params
    params.require(:user).permit(:email, :password, :name)
  end

  def view_param
    params[:view]&.to_sym
  end
end
