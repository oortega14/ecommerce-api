class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate_admin, only: %i[ create update destroy ]
  before_action :set_category, only: %i[ show update destroy ]

  # GET: '/api/v1/categories'
  def index
    categories = Category.includes(products: { attachments: { image_attachment: :blob } }).all
    render_with(categories, context: { view: view_param })
  end

  # GET: '/api/v1/categories/:id'
  def show
    render_with(@category, context: { view: view_param })
  end

  # POST: '/api/v1/categories'
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

  # PUT: '/api/v1/categories/:id'
  def update
    Category.transaction do
      if @category.update(category_params)
        render json: @category, include: [ :products ]
      else
        render json: { errors: @category.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  # DELETE: '/api/v1/categories/:id'
  def destroy
    @category.destroy
    head :no_content
  end

  private

  def view_param
    params[:view]&.to_sym
  end

  def set_category
    @category = Category.includes(:products).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Category not found' }, status: :not_found
  end

  def category_params
    params.require(:category).permit(:name, :description, product_ids: [])
  end
end
