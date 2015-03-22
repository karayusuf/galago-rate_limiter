require "json"
require "dalli"
require_relative "./rate_limiter/configuration"
require_relative "./rate_limiter/memcached_counter"
require_relative "./rate_limiter/redis_counter"
require_relative "./rate_limiter/railtie" if defined?(Rails)

module Galago
  class RateLimiter
    X_LIMIT_HEADER = 'X-RateLimit-Limit'.freeze
    X_RESET_HEADER = 'X-RateLimit-Reset'.freeze
    X_REMAINING_HEADER = 'X-RateLimit-Remaining'.freeze

    def self.configure
      yield Configuration.instance
    end

    def initialize(app)
      @app = app
      @config = Configuration.instance
      @counter = @config.counter
    end

    def call(env)
      api_key = env[@config.api_key_header]
      return @app.call(env) if api_key.nil?
      throughput = @counter.increment(api_key, 1, expires_in: expires_in)

      if limit_exceeded?(throughput)
        status = 403
        headers = {
          X_LIMIT_HEADER => @config.limit.to_s,
          X_REMAINING_HEADER => "0",
          X_RESET_HEADER => limit_resets_at.to_s
        }
        body = [JSON(message: "API rate limit exceeded for #{api_key}")]
      else
        status, headers, body = @app.call(env)
        headers[X_LIMIT_HEADER] = @config.limit.to_s
        headers[X_REMAINING_HEADER] = (@config.limit - throughput).to_s
        headers[X_RESET_HEADER] = limit_resets_at.to_s
      end

      [status, headers, body]
    end

    private

    def limit_exceeded?(throughput)
      throughput > @config.limit
    end

    def timestamp
      @timestamp ||= Time.now.utc.to_i
    end

    def expires_in
      timestamp % 3600
    end

    # Reset at the beginning of every hour.
    def limit_resets_at
      timestamp - (timestamp % 3600) + 3600
    end

  end
end

