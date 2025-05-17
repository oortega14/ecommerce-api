class Api::V1::ProductsController < ApplicationController
  before_action :admin_authorized, except: [ :index, :show ]
  before_action :set_product, only: [ :show, :update, :destroy ]

  def index
    products = Product.includes(:categories, :attachments, :creator).all
    render json: products, include: [ :categories, :attachments ]
  end

  def show
    render json: @product, include: [ :categories, :attachments ]
  end

  def create
    Product.transaction do
      product = Product.new(product_params)
      product.creator = current_user

      if product.save
        render json: product, include: [ :categories, :attachments ], status: :created
      else
        render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    Product.transaction do
      if @product.update(product_params)
        render json: @product, include: [ :categories, :attachments ]
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    @product.destroy
    head :no_content
  end

  private

  def set_product
    @product = Product.includes(:categories, :attachments).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  def product_params
    params.require(:product).permit(
      :name,
      :description,
      :price,
      :stock,
      category_ids: [],
      attachments_attributes: [
        :id,
        :_destroy,
        image: []
      ]
    )
  end
end
