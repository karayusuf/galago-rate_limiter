module Galago
  class RateLimiter::Railtie < ::Rails::Railtie
    initializer "galago.rate_limiter.configure_counter" do |app|
      app.config.middleware.use "Galago::RateLimiter"

      RateLimiter.configure do |config|
        config.counter = Rails.cache
      end
    end
  end
end

