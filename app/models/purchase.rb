class Purchase < ApplicationRecord
  # Associations
  belongs_to :client, class_name: 'User'
  belongs_to :product

  # Validations
  validates :quantity, presence: true, numericality: { greater_than: 0 }
  validates :total_price, presence: true, numericality: { greater_than: 0 }

  # Callbacks
  after_commit :check_first_purchase, on: :create

  private

  def check_first_purchase
    product_key = "product_first_purchase:#{product_id}"

    result = $redis.set(product_key, 1, nx: true, ex: 86400)
    if result && product.purchases.count == 1
      ProductMailer.first_purchase_notification(product, self).deliver_later
    end
  end
end
