# Galago::RateLimiter

Galago::RateLimiter is a middleware that provides github style rate limiting to
any Rack application. It has built in support for Rails and can be used by
simply adding it to your gemfile.

The middleware will add the following HTTP headers to any API request:

<dl>
  <dt>X-RateLimit-Limit</dt>
  <dl>The maximum number of requests that the consumer is permitted to make per hour.</dl>

  <dt>X-RateLimit-Remaining</dt>
  <dl>The number of requests remaining in the current rate limit window.</dl>

  <dt>X-RateLimit-Reset</dt>
  <dl>The time at which the current rate limit window resets in UTC epoch seconds.</dl>
</dl>

#### Response when the limit has not been exceeded
```
$ curl -X GET https://api.example.com/users/whatever -H 'X-Api-Key: Foo' -i

HTTP/1.1 200 OK
Date: Sun, 22 Mar 2015 12:32:06 GMT
Status: 200 OK
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 3761
X-RateLimit-Reset: 1372700873
```

#### Response for an exceeded limit
```
$ curl -X GET https://api.example.com/users/whatever -H 'X-Api-Key: Foo' -i

HTTP/1.1 403 Forbidden
Date: Sun, 22 Mar 2015 12:32:06 GMT
Status: 403 Forbidden
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 0
X-RateLimit-Reset: 1427083200

{"message":"API rate limit exceeded for Foo"}
```


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'galago-rate_limiter'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install galago-rate_limiter

## Configuration
```ruby
Galago::RateLimiter.configure do |config|
  # Number of requests a consumer is allowed to make per hour.
  # Default: 5_000
  config.limit = 20_000

  # The header containing the consumer's api key.
  # Default: 'X-Api-Key'
  config.api_key_header = 'Some-Header'

  # The object that will be used to increment the count of requests made by the consumer.
  # Must be one of:
  #   - Instance of Dalli::Client
  #   - Instance of Redis
  #   - Object that responds to `increment(key, amount, options = {})`
  #
  # Default: Rails.cache when used with Rails, otherwise must be provided.
  config.counter = Dalli::Client.new('localhost:11211', {
    namespace: 'galago-rate_limiter',
    compress: true
  })

  # Callback that will be executed on every consumer request that exceeds the
  # rate limit. The api_key of the current consumer will be yielded.
  #
  # Default: None
  config.callback do |api_key|
    # Execute your code here...
    # Would be useful for determining how often a specific customer or all
    # customers are hitting the limit.
  end
end
```

## Usage
### Rails
The rate limiter uses a Railtie add itself to the middleware of your Rails
application. You can override any of the defaults updating the config in an
initializer.

### Rack
```ruby
# config.ru
require 'galago/rate_limiter'

Galago::RateLimiter.configure do |config|
  # See example configuration above.
end

use Galago::RateLimiter
run lambda { |env| [200, {}, ['Hello There']] }
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/galago-rate_limiter/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
