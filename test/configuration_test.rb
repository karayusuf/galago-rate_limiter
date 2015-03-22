require 'minitest/autorun'
require File.expand_path('../../lib/galago/rate_limiter.rb', __FILE__)

module Galago
  class ConfigurationTest < Minitest::Unit::TestCase
    def setup
      @config = RateLimiter::Configuration.instance
      @config.reset!
    end

    def test_defaults
      assert_equal RateLimiter::Configuration::DEFAULT_LIMIT, @config.limit
      assert_equal RateLimiter::Configuration::DEFAULT_API_KEY_HEADER, @config.api_key_header
    end

    def test_setting_api_key_header
      @config.api_key_header = 'X-Foo-Bar'
      assert_equal 'HTTP_X_FOO_BAR', @config.api_key_header
    end

    def test_setting_limit
      @config.limit = 30_000
      assert_equal 30_000, @config.limit
    end

    def test_setting_limit_to_zero
      assert_raises(ArgumentError) { @config.limit = 0 }
    end
  end
end

