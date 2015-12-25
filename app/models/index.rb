class Index
  class NoredisInstance < StandardError; end

  attr_reader :redis

  def initialize(redis = nil)
    @redis = redis || Redis.current
    raise NoredisInstance unless @redis
  end

  def add_app(app)
    redis.sadd('maintenance:apps', app)
  end

  def remove_app(app)
    redis.srem('maintenance:apps', app)
  end

  def apps
    apps = redis.smembers('maintenance:apps')
    apps ? apps.sort : []
  end
end
