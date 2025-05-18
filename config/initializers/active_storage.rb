Rails.application.routes.default_url_options[:host] = ENV.fetch('HOST', 'localhost:3000')
