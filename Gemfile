source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '~> 7.2.1'
# Use postgresql as the database for Active Record
gem 'pg', '~> 1.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '~> 3.1.7'

# Use JWT gem for 'Json Web Tokens'
gem 'jwt', '~> 2.10'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[ windows jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Rack CORS for handling Cross-Origin Resource Sharing (CORS), making cross-origin Ajax possible
gem 'rack-cors'

# Background jobs with Sidekiq
gem 'sidekiq', '~> 8.0'

# Scheduled jobs with Sidekiq-Cron
gem 'sidekiq-cron', '~> 2.3'

# Audited gem for tracking changes
gem 'audited', '~> 5.8'

# Redis gem for caching
gem 'redis', '~> 5.4'

# Rswag gem for API documentation
gem 'rswag', '~> 2.16'

# JsonApiResponses for formatting responses
gem 'jsonapi_responses', '~> 0.1.2'

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[ mri windows ], require: 'debug/prelude'

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem 'brakeman', require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem 'rubocop-rails-omakase', require: false

  # Necessary gems for testing
  gem 'rspec-rails', '~> 8.0'
  gem 'database_cleaner', '~> 2.1'
  gem 'factory_bot', '~> 6.5'
  gem 'capybara', '~> 3.40'
  gem 'rubocop', '~> 1.75'
  gem 'shoulda-matchers', '~> 6.1'

  # Search for N+1 queries
  gem 'bullet', '~> 8.0'
end
