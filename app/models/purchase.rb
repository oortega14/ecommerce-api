class Purchase < ApplicationRecord
  # Associations
  belongs_to :client, class_name: 'User'
  belongs_to :product

  # Validations
  validates :quantity, :total_price, presence: true

  # Callbacks
  after_create :handle_first_purchase_email

  private

  def handle_first_purchase_email
    # Acá va la lógica (puede delegar a un job de Sidekiq)
  end
end
