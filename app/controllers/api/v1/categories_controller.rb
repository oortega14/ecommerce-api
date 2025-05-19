class Api::V1::CategoriesController < ApplicationController
  before_action :authenticate_admin, only: %i[ create update destroy ]
  before_action :set_category, only: %i[ show update destroy ]

  # GET: '/api/v1/categories'
  def index
    categories = Category.includes(products: { attachments: { image_attachment: :blob } }).all
    render_with(categories, context: { view: params[:view] })
  end

  # GET: '/api/v1/categories/:id'
  def show
    render_with(@category, context: { view: params[:view] })
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
    render_with(@category, context: { view: params[:view] })
  end

  # DELETE: '/api/v1/categories/:id'
  def destroy
    render_with(@category)
  end

  # GET: '/api/v1/categories/:id/audits'
  def audits
    category = Category.includes(audits: :user).find(params[:id])
    render json: category.audits.map { |audit|
      {
        action: audit.action,
        user: audit.user&.email,
        changes: audit.audited_changes,
        created_at: audit.created_at
      }
    }
  end

  private

  def set_category
    @category = Category.includes(:products).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ApiExceptions::BaseException.new(:RECORD_NOT_FOUND, [], {})
  end

  def category_params
    params.require(:category).permit(:name, :description, product_ids: [])
  end
end
