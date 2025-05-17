class DigitalProduct < Product
  # Validaciones específicas para productos digitales
  validates :download_url, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  validates :file_format, presence: true

  # Los productos digitales no tienen stock físico, siempre hay disponibilidad
  before_validation :set_unlimited_stock, on: :create

  # Los productos digitales no requieren envío
  def requires_shipping?
    false
  end

  # Proceso de compra específico para productos digitales
  def purchase_by(user)
    purchase = purchases.create!(client: user, quantity: 1, total_price: price)

    # Enviar correo con enlace de descarga
    ProductMailer.download_link(user, self).deliver_later

    purchase
  end

  private

  def set_unlimited_stock
    self.stock = 999999 # Valor arbitrariamente alto para representar stock ilimitado
  end
end
