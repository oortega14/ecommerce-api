class FirstPurchaseEmailJob < ApplicationJob
  queue_as :default

  def perform(client_id, purchase_id)
    client = User.find(client_id)
    purchase = Purchase.find(purchase_id)

    # Aquí iría la lógica para enviar el email
    # Por ejemplo:
    # PurchaseMailer.first_purchase(client, purchase).deliver_now
  end
end
