require 'sidekiq'
require 'sidekiq-cron'

# Configurar Sidekiq
Sidekiq.configure_server do |config|
  # Cargar el archivo de programaciu00f3n de tareas
  schedule_file = Rails.root.join('config', 'schedule.yml')

  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file)
    Rails.logger.info "Sidekiq-cron schedule loaded from #{schedule_file}"
  else
    Rails.logger.error "Schedule file #{schedule_file} not found. Cron jobs not loaded."
  end
end
