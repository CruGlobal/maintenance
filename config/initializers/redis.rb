# frozen_string_literal: true

require "redis"

Redis.current = Redis.new(host: ENV.fetch("REDIS_PORT_6379_TCP_ADDR"), db: 3)
