class Purchase < ApplicationRecord
  # Associations
  belongs_to :client, class_name: 'User'
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  after_commit :handle_first_purchase_email, on: :create
  after_create :send_first_purchase_notification

  private

  def handle_first_purchase_email
    FirstPurchaseEmailJob.perform_later(client_id, id)
  end

  # Enviar notificaciu00f3n de primera compra si es la primera vez que se compra el producto
  def send_first_purchase_notification
    # Verificar si es la primera compra para este producto
    if product.purchases.count == 1
      # Enviar correo al creador del producto y cc a otros administradores
      ProductMailer.first_purchase_notification(product, self).deliver_later
    end
  end
end
