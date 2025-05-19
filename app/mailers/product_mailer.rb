class ProductMailer < ApplicationMailer
  def first_purchase_notification(product, purchase)
    @product = product
    @purchase = purchase
    @client = purchase.client
    @creator = product.creator

    @other_admins = User.admin.where.not(id: @creator.id)

    to_email = @creator.email
    cc_emails = @other_admins.pluck(:email)

    subject = "Primera compra de tu producto: #{@product.name}"

    mail(to: to_email, cc: cc_emails, subject: subject)
  end

  def daily_purchase_report
    @date = Date.yesterday
    @purchases = Purchase.where(created_at: @date.beginning_of_day..@date.end_of_day)
                        .includes(:product, :client)

    @products_summary = {}
    @purchases.each do |purchase|
      product_id = purchase.product_id
      @products_summary[product_id] ||= {
        product: purchase.product,
        total_quantity: 0,
        total_revenue: 0,
        purchases_count: 0
      }

      @products_summary[product_id][:total_quantity] += purchase.quantity
      @products_summary[product_id][:total_revenue] += purchase.total_price
      @products_summary[product_id][:purchases_count] += 1
    end

    @total_daily_revenue = @purchases.sum(:total_price)

    admin_emails = User.admin.pluck(:email)

    subject = "Reporte de compras del #{@date.strftime('%d/%m/%Y')}"

    mail(to: admin_emails, subject: subject)
  end

  def download_link(user, digital_product)
    @user = user
    @product = digital_product
    @download_url = @product.download_url

    subject = "Tu descarga para: #{@product.name}"

    mail(to: @user.email, subject: subject)
  end

  def purchase_confirmation(user, physical_product, purchase)
    @user = user
    @product = physical_product
    @purchase = purchase
    @shipping_cost = @product.shipping_cost

    subject = "Confirmación de compra: #{@product.name}"

    mail(to: @user.email, subject: subject)
  end
end
