class StatsService
  # Obtener los productos mu00e1s vendidos por cantidad para cada categoru00eda
  def self.top_products_by_quantity
    categories = Category.includes(:products)

    categories.map do |category|
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
  end

  # Obtener los productos mu00e1s vendidos por ingresos para cada categoru00eda
  def self.top_products_by_revenue(limit = 3)
    categories = Category.includes(:products)

    # Usar el límite proporcionado o el valor predeterminado
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
            total_revenue: product.total_revenue
          }
        end
      }
    end
  end

  # Obtener compras filtradas
  def self.filtered_purchases(params)
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

  # Obtener conteo de compras agrupadas por tiempo
  def self.purchase_counts_by_time(params)
    purchases = filtered_purchases(params)
    granularity = params[:granularity] || 'day'

    format_string = case granularity.downcase
    when 'hour'
                      'YYYY-MM-DD HH24:00'
    when 'day'
                      'YYYY-MM-DD'
    when 'week'
                      'YYYY-WW' # Au00f1o-Semana
    when 'year'
                      'YYYY'
    else
                      'YYYY-MM-DD' # Default a du00eda
    end

    # Usar TO_CHAR para PostgreSQL en lugar de DATE_FORMAT
    counts = purchases.group("TO_CHAR(purchases.created_at, '#{format_string}')").count

    counts.transform_keys do |key|
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
  end
end
