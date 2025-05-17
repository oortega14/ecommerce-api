class Purchase < ApplicationRecord
  # Associations
  belongs_to :client, class_name: 'User'
  belongs_to :product

  # Validations
  validates :quantity, :total_price, presence: true

  # Callbacks
  after_commit :handle_first_purchase_email, on: :create

  private

  def handle_first_purchase_email
    FirstPurchaseEmailJob.perform_later(client_id, id)
  end
end
