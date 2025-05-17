class DailyPurchaseReportJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info 'Iniciando generaciu00f3n del reporte diario de compras...'
    ProductMailer.daily_purchase_report.deliver_now
    Rails.logger.info 'Reporte diario de compras enviado correctamente.'
  end
end
