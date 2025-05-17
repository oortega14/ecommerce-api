class Api::V1::StatsController < ApplicationController
  # GET /api/v1/stats/top_products
  def top_products
    categories = Category.includes(:products)

    result = categories.map do |category|
      top_products = category.products
                            .joins(:purchases)
                            .select('products.*, SUM(purchases.quantity) as total_quantity')
                            .group('products.id')
                            .order('total_quantity DESC')
                            .limit(5)

      {
        category_id: category.id,
        category_name: category.name,
        top_products: top_products.map do |product|
          {
            id: product.id,
            name: product.name,
            total_quantity: product.total_quantity
          }
        end
      }
    end

    render json: result
  end

  # GET /api/v1/stats/most_purchased
  def most_purchased
    categories = Category.includes(:products)

    result = categories.map do |category|
      top_products = category.products
                            .joins(:purchases)
                            .select('products.*, SUM(purchases.total_price) as total_revenue')
                            .group('products.id')
                            .order('total_revenue DESC')
                            .limit(3)

      {
        category_id: category.id,
        category_name: category.name,
        top_revenue_products: top_products.map do |product|
          {
            id: product.id,
            name: product.name,
            total_revenue: product.total_revenue
          }
        end
      }
    end

    render json: result
  end

  # GET /api/v1/stats/purchases
  def purchases
    purchases = filter_purchases

    render json: purchases.includes(:product, :client)
  end

  # GET /api/v1/stats/purchase_counts
  def purchase_counts
    purchases = filter_purchases
    granularity = params[:granularity] || 'day'

    format_string = case granularity.downcase
    when 'hour'
                      '%Y-%m-%d %H:00'
    when 'day'
                      '%Y-%m-%d'
    when 'week'
                      '%Y-%U' # Año-Semana
    when 'year'
                      '%Y'
    else
                      '%Y-%m-%d' # Default a día
    end

    counts = purchases.group("DATE_FORMAT(purchases.created_at, '#{format_string}')").count

    result = counts.transform_keys do |key|
      case granularity.downcase
      when 'hour'
        key
      when 'day'
        key
      when 'week'
        year, week = key.split('-')
        "Semana #{week} de #{year}"
      when 'year'
        key
      else
        key
      end
    end

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
