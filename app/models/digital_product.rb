class DigitalProduct < Product
  # Validations
  validates :download_url, presence: true
  validates :file_size, presence: true, numericality: { greater_than: 0 }
  validates :file_format, presence: true

  before_validation :set_unlimited_stock, on: :create

  def requires_shipping?
    false
  end

  def purchase_by(user)
    purchase = purchases.create!(client: user, quantity: 1, total_price: price)
    ProductMailer.download_link(user, self).deliver_later

    purchase
  end

  private

  def set_unlimited_stock
    self.stock = 999999
  end
end
