class Api::V1::CategoriesController < ApplicationController
  before_action :admin_authorized, except: [ :index, :show ]
  before_action :set_category, only: [ :show, :update, :destroy ]

  def index
    categories = Category.includes(:products).all
    render json: categories, include: [ :products ]
  end

  def show
    render json: @category, include: [ :products ]
  end

  def create
    Category.transaction do
      category = Category.new(category_params)
      category.creator = current_user

      if category.save
        render json: category, include: [ :products ], status: :created
      else
        render json: { errors: category.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    Category.transaction do
      if @category.update(category_params)
        render json: @category, include: [ :products ]
      else
        render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @category.destroy
    head :no_content
  end

  private

  def set_category
    @category = Category.includes(:products).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Category not found' }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name, :description, product_ids: [])
  end
end
