require "json"
require "dalli"
require_relative "./rate_limiter/counter"

module Galago
  class RateLimiter
    # The maximum number of requests that the consumer is permitted to make per hour.
    X_LIMIT_HEADER = 'X-RateLimit-Limit'.freeze

    # The time at which the current rate limit window resets in UTC epoch seconds.
    X_RESET_HEADER = 'X-RateLimit-Reset'.freeze

    # The number of requests remaining in the current rate limit window.
    X_REMAINING_HEADER = 'X-RateLimit-Remaining'.freeze

    # The header that contains the consumer's api key.
    API_KEY_HEADER = 'X-Api-Key'.freeze

    # The maximum number of requests that the consumer is permitted to make per hour.
    LIMIT = 5000

    def initialize(app)
      @app = app
      @counter = RateLimiter::Counter.instance
    end

    def call(env)
      api_key = env[API_KEY_HEADER]
      throughput = @counter.increment(api_key, expires_in)

      if limit_exceeded?(throughput)
        status = 403
        headers = {
          X_LIMIT_HEADER => LIMIT,
          X_REMAINING_HEADER => 0,
          X_RESET_HEADER => limit_resets_at
        }
        body = JSON(message: "API rate limit exceeded for #{api_key}")
      else
        status, headers, body = @app.call(env)
        headers[X_LIMIT_HEADER] = LIMIT
        headers[X_REMAINING_HEADER] = (LIMIT - throughput)
        headers[X_RESET_HEADER] = limit_resets_at
      end

      [status, headers, body]
    end

    private

    def limit_exceeded?(throughput)
      throughput > LIMIT
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

