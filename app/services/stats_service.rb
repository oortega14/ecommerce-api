class StatsService
  def self.top_products_by_quantity
    categories = Category.includes(:products)

    categories.map do |category|
      top_products = category.products
                            .joins(:purchases)
                            .select('products.*, SUM(purchases.quantity) as total_quantity')
                            .group('products.id')
                            .order('total_quantity DESC')
                            .limit(2)

      {
        category_id: category.id,
        category_name: category.name,
        top_products: top_products.map do |product|
          {
            id: product.id,
            name: product.name,
            total_quantity: product.total_quantity.to_i
          }
        end
      }
    end
  end

  def self.top_products_by_revenue(limit = 3)
    categories = Category.includes(:products)

    limit = limit.to_i > 0 ? limit.to_i : 3

    categories.map do |category|
      top_products = category.products
                            .joins(:purchases)
                            .select('products.*, SUM(purchases.total_price) as total_revenue')
                            .group('products.id')
                            .order('total_revenue DESC')
                            .limit(limit)

      {
        category_id: category.id,
        category_name: category.name,
        top_products: top_products.map do |product|
          {
            id: product.id,
            name: product.name,
            total_revenue: product.total_revenue.to_f.round(2)
          }
        end
      }
    end
  end

  def self.filtered_purchases(params)
    purchases = Purchase.all.includes(:product, :client)

    if params[:start_date].present?
      begin
        start_date = Date.parse(params[:start_date]).beginning_of_day
        purchases = purchases.where('purchases.created_at >= ?', start_date)
      rescue ArgumentError
        raise ApiExceptions::BaseException.new(:INVALID_DATE_FORMAT, [], {})
      end
    end

    if params[:end_date].present?
      begin
        end_date = Date.parse(params[:end_date]).end_of_day
        purchases = purchases.where('purchases.created_at <= ?', end_date)
      rescue ArgumentError
      end
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

  def self.purchase_counts_by_time(params)
    purchases = filtered_purchases(params)
    granularity = params[:granularity]&.downcase || 'day'

    format_string = case granularity
    when 'hour'
      'YYYY-MM-DD HH24:00'
    when 'day'
      'YYYY-MM-DD'
    when 'week'
      'IYYY-IW'
    when 'year'
      'YYYY'
    else
      'YYYY-MM-DD'
    end

    counts = purchases.group("TO_CHAR(purchases.created_at, '#{format_string}')").count

    formatted_counts = {}

    counts.each do |key, value|
      formatted_key = case granularity
      when 'hour', 'day', 'year'
        key
      when 'week'
        year, week = key.split('-')
        "Week #{week} of #{year}"
      else
        key
      end

      formatted_counts[formatted_key] = value
    end

    formatted_counts
  end
end
