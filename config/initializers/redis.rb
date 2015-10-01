require 'redis'
require 'redis/namespace'

Redis.current = Redis::Namespace.new("maintenance:#{Rails.env}", redis: Redis.new(host: ENV.fetch('REDIS_PORT_6379_TCP_ADDR')))
