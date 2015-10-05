require 'redis'
require 'redis/namespace'

Redis.current = Redis::Namespace.new("maintenance:#{ENV.fetch('ENVIRONMENT')}", redis: Redis.new(host: ENV.fetch('REDIS_PORT_6379_TCP_ADDR')))
