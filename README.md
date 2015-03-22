# Galago::RateLimiter

Galago::RateLimiter is middleware that provides github style rate limiting to
any Rack application. It has built in support for Rails and can be used by
simply adding it to your gemfile.

The middleware will add the following HTTP headers to any API request:

| Header Name | Description |
| ----------- | ----------- |
| X-RateLimit-Limit | The maximum number of requests that the consumer is permitted to make per hour. |
| X-RateLimit-Remaining | The number of requests remaining in the current rate limit window. |
| X-RateLimit-Reset | The time at which the current rate limit window resets in UTC epoch seconds. |

Example:

```
$ curl -i https://api.example.com/users/whatever

HTTP/1.1 200 OK
Date: Sun, 22 Mar 2015 12:32:06 GMT
Status: 200 OK
X-RateLimit-Limit: 5000
X-RateLimit-Remaining: 3761
X-RateLimit-Reset: 1372700873
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

## Usage

### Configuration
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
end
```

### Rails
The rate limiter uses a Railtie add itself to the middleware of your Rails
application. You can override any of the defaults by adding an initializer and
configuring the middleware using the options shown above.

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
