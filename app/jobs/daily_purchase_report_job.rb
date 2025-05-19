class DailyPurchaseReportJob < ApplicationJob
  queue_as :default

  def perform
    ProductMailer.daily_purchase_report.deliver_now
  end
end
