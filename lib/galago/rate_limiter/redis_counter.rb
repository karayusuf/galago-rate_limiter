module Galago
  class RateLimiter
    class RedisCounter
      def initialize(client)
        @redis = client
      end

      def increment(key, amount, options = {})
        count, _ = @redis.multi do |multi|
          multi.incrby(key, amount)
          multi.expire(key, options[:expires_in])
        end
        count
      end

      def reset!
        @redis.flushdb
      end
    end
  end
end

