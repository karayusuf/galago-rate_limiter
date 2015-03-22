# Galago::RateLimiter

TODO: Write a gem description

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

| Name | Description | Default |
| ---- | ----------- | ------- |
| limit | Number of requests allow per hour | 5,000 |
| api_key_header | Header containing the consumers api key | 'X-Api-Key' |

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
