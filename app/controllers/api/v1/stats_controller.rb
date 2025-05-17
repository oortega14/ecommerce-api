class Api::V1::StatsController < ApplicationController
  before_action :admin_authorized

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

  private

  def filter_purchases
    purchases = Purchase.all

    if params[:start_date].present?
      purchases = purchases.where('purchases.created_at >= ?', params[:start_date].to_date.beginning_of_day)
    end
    if params[:end_date].present?
      purchases = purchases.where('purchases.created_at <= ?', params[:end_date].to_date.end_of_day)
    end

    if params[:category_id].present?
      purchases = purchases.joins(product: :categories)
                          .where('categories.id = ?', params[:category_id])
    end

    if params[:client_id].present?
      purchases = purchases.where(client_id: params[:client_id])
    end

    if params[:admin_id].present?
      purchases = purchases.joins(:product)
                          .where('products.creator_id = ?', params[:admin_id])
    end

    purchases
  end
end
