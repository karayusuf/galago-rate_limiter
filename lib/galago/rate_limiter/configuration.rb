require 'singleton'

module Galago
  class RateLimiter
    class Configuration
      include Singleton

      attr_accessor :limit
      attr_reader :api_key_header

      def initialize
        @limit = 5_000
        @api_key_header = 'HTTP_X_API_KEY'.freeze
      end

      def api_key_header=(api_key_header)
        header = api_key_header.dup
        header.gsub!('-', '_')
        header.upcase!

        @api_key_header = "HTTP_#{api_key_header}".freeze
      end

    end
  end
end

