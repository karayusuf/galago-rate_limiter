require 'minitest/autorun'
require File.expand_path('../../lib/galago/rate_limiter.rb', __FILE__)

module Galago
  class RateLimiterTest < Minitest::Unit::TestCase
    def setup
      RateLimiter::Counter.instance.reset!
      @app = lambda { |env| [200, {}, ["Hello There"]] }
      @rate_limiter = RateLimiter.new(@app)
    end

    def test_limit_header
      status, headers, body = @rate_limiter.call('X-Api-Key' => 'some-key')
      assert_equal RateLimiter::LIMIT, headers['X-RateLimit-Limit']
    end

    def test_remaining_request_header
      status, headers, body = @rate_limiter.call('X-Api-Key' => 'some-key')
      assert_equal RateLimiter::LIMIT - 1, headers['X-RateLimit-Remaining']
    end

    def test_reset_header
      time = Time.now.utc.to_i
      start_of_next_hour = time - (time % 3600) + 3600

      status, headers, body = @rate_limiter.call('X-Api-Key' => 'some-key')
      assert_equal start_of_next_hour, headers['X-RateLimit-Reset']
    end

    def test_response_when_limit_has_not_been_reached
      status, headers, body = @rate_limiter.call('X-Api-Key' => 'some-key')
      assert_equal 200, status
      assert_equal ["Hello There"], body
    end

    def test_response_when_limit_has_been_reached
      RateLimiter::LIMIT.times { @rate_limiter.call('X-Api-Key' => 'some-key') }
      status, headers, body = @rate_limiter.call('X-Api-Key' => 'some-key')
      assert_equal 403, status
      assert_equal({ "message" => "API rate limit exceeded for some-key" }, JSON.parse(body))
    end
  end
end

