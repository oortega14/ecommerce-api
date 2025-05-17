class Api::V1::ProductsController < ApplicationController
  skip_before_action :admin_authorized, only: [ :index, :show ]
  before_action :set_product, only: [ :show, :update, :destroy ]

  def index
    products = Product.includes(:categories, :creator).all
    render json: products
  end

  def show
    render json: @product, include: [ :categories ]
  end

  def create
    Product.transaction do
      product = Product.new(product_params)
      product.creator = current_user

      if product.save
        if params[:product][:category_ids].present?
          product.category_ids = params[:product][:category_ids]
        end

        render json: product, status: :created
      else
        render json: { errors: product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def update
    Product.transaction do
      if @product.update(product_params)
        if params[:product][:category_ids].present?
          @product.category_ids = params[:product][:category_ids]
        end

        render json: @product
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
    @product = Product.includes(:categories).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { error: 'Product not found' }, status: :not_found
  end

  def product_params
    params.require(:product).permit(:name, :description, :price, :stock)
  end
end
