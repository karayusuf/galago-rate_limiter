require 'singleton'

module Galago
  class RateLimiter
    class Configuration
      include Singleton

      DEFAULT_LIMIT = 5_000
      DEFAULT_API_KEY_HEADER = 'HTTP_X_API_KEY'.freeze

      attr_reader :api_key_header, :limit

      def initialize
        @limit = DEFAULT_LIMIT
        @api_key_header = DEFAULT_API_KEY_HEADER
      end

      def limit=(limit)
        raise ArgumentError.new("Limit must be a positive number") if limit < 1
        @limit = limit
      end

      def api_key_header=(api_key_header)
        header = api_key_header.dup
        header.gsub!('-', '_')
        header.upcase!

        @api_key_header = "HTTP_#{header}".freeze
      end

      def reset!
        @limit = DEFAULT_LIMIT
        @api_key_header = DEFAULT_API_KEY_HEADER
      end

    end
  end
end

