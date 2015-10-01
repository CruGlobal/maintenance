class Index
  class NoredisInstance < StandardError; end

  attr_reader :redis

  def initialize(redis = nil)
    @redis = redis || Redis.current
    raise NoredisInstance unless @redis
  end

  def add_app(app)
    redis.sadd(:apps, app)
  end

  def remove_app(app)
    redis.srem(:apps, app)
  end

  def apps
    apps = redis.smembers(:apps)
    apps ? apps.sort : []
  end
end
