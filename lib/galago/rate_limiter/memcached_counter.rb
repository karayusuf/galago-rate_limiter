module Galago
  class RateLimiter
    class MemcachedCounter
      def initialize(client)
        @memcached = client
      end

      def increment(key, amount, options = {})
        @memcached.incr(key, amount, options[:expires_in], 1)
      end

      def reset!
        @memcached.flush
      end
    end
  end
end

