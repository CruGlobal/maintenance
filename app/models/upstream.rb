# frozen_string_literal: true

class Upstream
  attr_reader :pattern, :target, :redis

  TARGETS = {"Cru WordPress": "WP_ADDR",
             "WordPress VIP": "VIP_ADDR",
             Storylines: "STORYLINES_ADDR",
             "Cru.org (Default)": "DEFAULT_PROXY_TARGET"}.freeze

  def initialize(pattern, target = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @pattern = pattern
    @existing_target = Upstream.hash[pattern]
    @target = if @existing_target
      # Update if values were passed in. otherwise return existing
      target || @existing_target
    else
      target
    end

    self
  end

  def save
    unless @existing_target
      AuditEntry.create!(change_type: "add_upstream",
        key: upstream_key,
        to_value: target,
        user_id: Thread.current[:user_id])
    end
    if @existing_target && target != @existing_target
      AuditEntry.create!(change_type: "update_upstream",
        key: upstream_key,
        from_value: @existing_target,
        to_value: target,
        user_id: Thread.current[:user_id])
    end
    redis.hset(upstream_key, pattern, target)
  end

  def destroy
    redis.hdel(upstream_key, pattern)
    AuditEntry.create!(change_type: "remove_upstream",
      key: upstream_key,
      from_value: target,
      user_id: Thread.current[:user_id])
  end

  def self.all
    hash.sort.collect { |k, v| Upstream.new(k, v) }
  end

  def self.hash
    Redis.current.hgetall(upstream_key)
  end

  def created_at
    create_audit.try(:created_at)
  end

  def created_by
    create_audit.try(:user)
  end

  def updated_at
    update_audit.try(:created_at)
  end

  def updated_by
    update_audit.try(:user)
  end

  def create_audit
    @create_audit ||= AuditEntry.includes(:user).find_by(change_type: "add_upstream", key: upstream_key)
  end

  def update_audit
    @update_audit ||= AuditEntry.includes(:user)
      .where(change_type: "update_upstream", key: upstream_key)
      .order("created_at desc").first
  end

  def self.upstream_key
    "upstreams"
  end

  def upstream_key
    Upstream.upstream_key
  end

  def to_partial_path
    "upstream"
  end
end
