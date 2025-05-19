class Api::V1::StatsController < ApplicationController
  before_action :authenticate_admin

  # GET /api/v1/stats/top_products
  def top_products
    result = StatsService.top_products_by_quantity
    render json: result
  end

  # GET /api/v1/stats/most_purchased
  def most_purchased
    limit = params[:limit]
    result = StatsService.top_products_by_revenue(limit)
    render json: result
  end

  # GET /api/v1/stats/purchases
  def purchases
    purchases = StatsService.filtered_purchases(params)
    render json: purchases.includes(:product, :client)
  end

  # GET /api/v1/stats/purchase_counts
  def purchase_counts
    result = StatsService.purchase_counts_by_time(params)
    render json: result
  end
end
