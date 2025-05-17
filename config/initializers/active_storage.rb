# Configurar el host predeterminado para las URLs de Active Storage
Rails.application.routes.default_url_options[:host] = ENV.fetch('HOST', 'localhost:3000')
