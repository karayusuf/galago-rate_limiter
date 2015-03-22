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

      def increment(key, amount, options = {})
        @store.incr(key, amount, options[:expires_in], 1)
      end
    end
  end
end

