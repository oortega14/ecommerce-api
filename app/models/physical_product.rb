class PhysicalProduct < Product
  # Validaciones específicas para productos físicos
  validates :weight, presence: true, numericality: { greater_than: 0 }
  validates :dimensions, presence: true

  # Los productos físicos requieren control de inventario
  validate :stock_available, on: :update

  # Los productos físicos requieren envío
  def requires_shipping?
    true
  end

  # Cálculo de costo de envío basado en peso y dimensiones
  def shipping_cost
    # Implementación básica de cálculo de costo de envío
    base_cost = 5.0 # Costo base
    weight_factor = weight * 0.1 # $0.1 por cada unidad de peso

    base_cost + weight_factor
  end

  # Proceso de compra específico para productos físicos
  def purchase_by(user, quantity = 1)
    # Verificar stock disponible
    raise StandardError, 'No hay suficiente stock disponible' if quantity > stock

    # Crear la compra
    purchase = nil

    Product.transaction do
      # Reducir el stock
      self.stock -= quantity
      save!

      # Crear el registro de compra
      purchase = purchases.create!(
        client: user,
        quantity: quantity,
        total_price: price * quantity
      )
    end

    # Enviar correo de confirmación de compra
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
