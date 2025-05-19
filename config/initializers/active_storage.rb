# Set default URL options for ActiveStorage
host = ENV.fetch('HOST', 'localhost')
port = ENV.fetch('PORT', 3000)

# Set default URL options for routes
Rails.application.routes.default_url_options[:host] = host
Rails.application.routes.default_url_options[:port] = port

# Configure ActiveStorage URL options
Rails.application.config.after_initialize do
  ActiveStorage::Current.url_options = {
    host: host,
    port: port,
    protocol: 'http'
  }
end
