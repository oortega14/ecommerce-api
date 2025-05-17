class Api::V1::CategoriesController < ApplicationController
  skip_before_action :admin_authorized, only: [ :index, :show ]
  before_action :set_category, only: [ :show, :update, :destroy ]

  def index
    categories = Category.all
    render json: categories
  end

  def show
    render json: @category
  end

  def create
    category = Category.new(category_params)
    category.creator = current_user
    if category.save
      render json: category, status: :created
    else
      render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @category.update(category_params)
      render json: @category
    else
      render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Category not found' }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name, :description)
  end
end
