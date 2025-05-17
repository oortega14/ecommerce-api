class ProductMailer < ApplicationMailer
  # Notificar al creador del producto y a otros administradores sobre la primera compra
  def first_purchase_notification(product, purchase)
    @product = product
    @purchase = purchase
    @client = purchase.client
    @creator = product.creator

    # Obtener todos los administradores excepto el creador
    @other_admins = User.admin.where.not(id: @creator.id)

    # Destinatarios
    to_email = @creator.email
    cc_emails = @other_admins.pluck(:email)

    # Asunto del correo
    subject = "Primera compra de tu producto: #{@product.name}"

    # Enviar correo al creador con copia a otros administradores
    mail(to: to_email, cc: cc_emails, subject: subject)
  end

  # Enviar reporte diario de compras a todos los administradores
  def daily_purchase_report
    @date = Date.yesterday
    @purchases = Purchase.where(created_at: @date.beginning_of_day..@date.end_of_day)
                        .includes(:product, :client)

    # Agrupar compras por producto
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

    # Total de ingresos del du00eda
    @total_daily_revenue = @purchases.sum(:total_price)

    # Obtener todos los administradores
    admin_emails = User.admin.pluck(:email)

    # Asunto del correo
    subject = "Reporte de compras del #{@date.strftime('%d/%m/%Y')}"

    # Enviar correo a todos los administradores
    mail(to: admin_emails, subject: subject)
  end

  # Enviar enlace de descarga para productos digitales
  def download_link(user, digital_product)
    @user = user
    @product = digital_product
    @download_url = @product.download_url

    subject = "Tu descarga para: #{@product.name}"

    mail(to: @user.email, subject: subject)
  end

  # Enviar confirmaciu00f3n de compra para productos fu00edsicos
  def purchase_confirmation(user, physical_product, purchase)
    @user = user
    @product = physical_product
    @purchase = purchase
    @shipping_cost = @product.shipping_cost

    subject = "Confirmaciu00f3n de compra: #{@product.name}"

    mail(to: @user.email, subject: subject)
  end
end
