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
    category = Category.new(category_params)
    category.creator = current_user

    render_with(category)
  end

  # PUT: '/api/v1/categories/:id'
  def update
    @category.update(category_params)
    render_with(@category, context: { view: view_param })
  end

  # DELETE: '/api/v1/categories/:id'
  def destroy
    render_with(@category)
  end

  private

  def set_category
    @category = Category.includes(:products).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ApiExceptions::BaseException.new(:RECORD_NOT_FOUND, [], {})
  end

  def view_param
    params[:view]&.to_sym
  end

  def category_params
    params.require(:category).permit(:name, :description, product_ids: [])
  end
end
