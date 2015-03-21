require 'singleton'

module Galago
  class RateLimiter
    class Counter
      include Singleton

      def initialize
        @store = Dalli::Client.new('localhost:11211', {
          namespace: 'galago-rate_limiter',
          compress: true
        })
      end

      def reset!
        @store.flush
      end

      def increment(key, ttl)
        @store.incr(key, 1, ttl, 1)
      end
    end
  end
end

