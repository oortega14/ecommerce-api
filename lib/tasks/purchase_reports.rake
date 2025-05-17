namespace :purchase_reports do
  desc 'Enviar reporte diario de compras a todos los administradores'
  task send_daily_report: :environment do
    puts 'Enviando reporte diario de compras...'
    ProductMailer.daily_purchase_report.deliver_now
    puts 'Reporte enviado correctamente.'
  end
end
