class FirstPurchaseEmailJob < ApplicationJob
  queue_as :default

  def perform(purchase_id)
    purchase = Purchase.find_by(id: purchase_id)
    return unless purchase

    product = purchase.product


    ProductMailer.first_purchase_notification(product, purchase).deliver_now
  end
end
