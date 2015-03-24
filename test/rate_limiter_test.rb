require 'minitest/autorun'
require 'rack/test'
require 'dalli'

require File.expand_path('../../lib/galago/rate_limiter.rb', __FILE__)

module Galago
  class RateLimiterTest < Minitest::Unit::TestCase
    include Rack::Test::Methods

    attr_reader :app
    def setup
      @app = Rack::Builder.new do
        Galago::RateLimiter.configure do |config|
          config.limit = 10
          config.counter = Dalli::Client.new('localhost:11211')
          config.counter.reset!
        end

        use Galago::RateLimiter
        run lambda { |env| [200, {}, ["Hello There"]] }
      end
    end

    def send_request(api_key)
      get '/', {}, { 'HTTP_X_API_KEY' => api_key }
      last_response
    end

    def test_limit_header
      response = send_request('api-key')
      assert_equal '10', response.headers['X-RateLimit-Limit']
    end

    def test_remaining_request_header
      response = send_request('some-key')
      assert_equal "#{10 - 1}", response.headers['X-RateLimit-Remaining']
    end

    def test_reset_header
      time = Time.now.utc.to_i
      start_of_next_hour = time - (time % 3600) + 3600

      response = send_request('some-key')
      assert_equal "#{start_of_next_hour}", response.headers['X-RateLimit-Reset']
    end

    def test_response_when_no_api_key_is_provided
      response = send_request(nil)
      assert_nil response.headers['X-RateLimit-Limit']
      assert_nil response.headers['X-RateLimit-Remaining']
      assert_nil response.headers['X-RateLimit-Reset']
      assert_equal 200, response.status
      assert_equal "Hello There", response.body
    end

    def test_response_when_limit_has_not_been_reached
      response = send_request('foo')
      assert_equal 200, response.status
      assert_equal "Hello There", response.body
    end

    def test_response_when_limit_has_been_reached
      RateLimiter::Configuration.instance.limit.times { send_request('api-key') }

      response = send_request('api-key')
      assert_equal 403, response.status
      assert_equal({ "message" => "API rate limit exceeded for api-key" }, JSON.parse(response.body))
    end

    def test_callback_when_limit_has_been_reached
      @exceeded_api_key = nil

      Galago::RateLimiter.configure do |config|
        config.limit = 1
        config.callback { |api_key| @exceeded_api_key = api_key }
      end

      successful_response = send_request('api-key')
      assert_equal 200, successful_response.status
      assert_equal nil, @exceeded_api_key

      limit_exceeded_response = send_request('api-key')
      assert_equal 403, limit_exceeded_response.status
      assert_equal 'api-key', @exceeded_api_key
    end
  end
end

