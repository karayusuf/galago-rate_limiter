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

### Rails
The rate limiter uses a Railtie add itself to the middleware of your Rails
application. All you have to do is add an initializer file to configure the
settings.

```ruby
# config/initializers/galago_rate_limiter.rb
Galago::RateLimiter.configure do |config|
  config.limit = 20_000
  config.api_key_header = 'Some-Header'
end
```

### Rack
```ruby
require 'galago/rate_limiter'

Galago::RateLimiter.configure do |config|
  config.limit = 20_000
  config.api_key_header = 'Some-Header'
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
