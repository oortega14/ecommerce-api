require 'redis'

# Configure Redis connection
redis_config = {
  url: ENV.fetch('REDIS_URL') { 'redis://localhost:6379/1' },
  timeout: 1
}

# Create a global Redis instance
$redis = Redis.new(redis_config)

# Set up a Redis namespace for the application
Rails.application.config.redis_namespace = 'ecommerce_api'
