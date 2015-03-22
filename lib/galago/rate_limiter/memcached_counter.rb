require 'singleton'

module Galago
  class RateLimiter
    class MemcachedCounter
      def initialize(client)
        @client = client
      end

      def increment(key, amount, options = {})
        @client.incr(key, amount, options[:expires_in], 1)
      end

      def reset!
        @client.flush
      end
    end
  end
end

