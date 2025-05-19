class PhysicalProduct < Product
  # Validaciones específicas para productos físicos
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :dimensions, presence: true

  # Los productos físicos requieren control de inventario
  validate :stock_available, on: :update

  def requires_shipping?
    true
  end

  def shipping_cost
    base_cost = 5.0
    weight_factor = weight * 0.1

    base_cost + weight_factor
  end

  def purchase_by(user, quantity = 1)
    raise StandardError, 'Not enough stock available' if quantity > stock

    purchase = nil

    Product.transaction do
      self.stock -= quantity
      save!

      purchase = purchases.create!(
        client: user,
        quantity: quantity,
        total_price: price * quantity
      )
    end

    ProductMailer.purchase_confirmation(user, self, purchase).deliver_later

    purchase
  end

  private

  def stock_available
    if stock_changed? && stock < 0
      errors.add(:stock, 'no puede ser negativo')
    end
  end
end
