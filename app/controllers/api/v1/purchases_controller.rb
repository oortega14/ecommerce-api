class Api::V1::PurchasesController < ApplicationController
  # GET /api/v1/purchases
  def index
    @purchases = current_user.purchases.includes(:product).order(created_at: :desc)
    render json: @purchases
  end

  # GET /api/v1/purchases/:id
  def show
    @purchase = find_purchase
    if @purchase
      render json: @purchase
    else
      render json: { error: 'Purchase not found' }, status: :not_found
    end
  end

  # POST /api/v1/purchases
  def create
    Purchase.transaction do
      @purchase = current_user.purchases.new(purchase_params)
      if @purchase.product.nil?
        render json: { errors: [ 'Product must exist' ] }, status: :unprocessable_entity
        return
      end

      @purchase.total_price = @purchase.quantity * @purchase.product.price

      if @purchase.save
        render json: @purchase, status: :created
      else
        render json: { errors: @purchase.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def find_purchase
    current_user.purchases.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def purchase_params
    params.require(:purchase).permit(:product_id, :quantity)
  end
end
