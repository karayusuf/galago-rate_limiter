require 'galago/rate_limiter'

use Galago::RateLimiter
run lambda { |env| [200, {}, ['Hello There']] }

