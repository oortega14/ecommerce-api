class Api::V1::PurchasesController < ApplicationController
  before_action :authenticate_user
  before_action :set_purchase, only: %i[ show ]

  # GET /api/v1/purchases
  def index
    purchases = if current_user.admin?
      Purchase.all.order(created_at: :desc)
    else
      current_user.purchases.order(created_at: :desc)
    end
    render_with(purchases, context: { view: view_param })
  end

  # GET /api/v1/purchases/:id
  def show
    render_with(@purchase, context: { view: view_param })
  end

  # POST /api/v1/purchases
  def create
    purchase = Purchase.new(purchase_params)
    if purchase.product.nil?
      render json: { errors: [ 'Product must exist' ] }, status: :unprocessable_entity
      return
    end

    purchase.client = current_user
    purchase.total_price = purchase.quantity * purchase.product.price
    debugger

    render_with(purchase)
  end

  private

  def set_purchase
    @purchase = current_user.admin? ? Purchase.find(params[:id]) : current_user.purchases.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise ApiExceptions::BaseException.new(:RECORD_NOT_FOUND, [], {})
  end

  def purchase_params
    params.require(:purchase).permit(:product_id, :quantity)
  end

  def view_param
    params[:view]&.to_sym
  end
end
