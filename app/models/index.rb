# frozen_string_literal: true

class Index
  class NoredisInstance < StandardError; end

  attr_reader :redis

  def initialize(redis = nil)
    @redis = redis || Redis.current
    raise NoredisInstance unless @redis
  end

  def add_app(app)
    redis.sadd(apps_key, app)
    AuditEntry.create!(change_type: "add_app",
      key: apps_key,
      to_value: app,
      user_id: Thread.current[:user_id])
  end

  def remove_app(app)
    redis.srem(apps_key, app)
    AuditEntry.create!(change_type: "remove_app",
      key: apps_key,
      from_value: app,
      user_id: Thread.current[:user_id])
  end

  def apps
    apps = redis.smembers(apps_key)
    apps ? apps.sort : []
  end

  def apps_key
    "maintenance:apps"
  end
end
