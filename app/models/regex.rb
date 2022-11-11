# frozen_string_literal: true

class Regex
  attr_reader :pattern, :target, :redis

  def initialize(pattern, target = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @pattern = pattern
    @existing_target = Regex.hash[pattern]
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
      AuditEntry.create!(change_type: "add_regex",
        key: regex_key,
        to_value: target,
        user_id: Thread.current[:user_id])
    end
    if @existing_target && target != @existing_target
      AuditEntry.create!(change_type: "update_regex",
        key: regex_key,
        from_value: @existing_target,
        to_value: target,
        user_id: Thread.current[:user_id])
    end
    redis.hset(regex_key, pattern, target)
  end

  def destroy
    redis.hdel(regex_key, pattern)
    AuditEntry.create!(change_type: "remove_regex",
      key: regex_key,
      from_value: target,
      user_id: Thread.current[:user_id])
  end

  def self.all
    hash.sort.collect { |k, v| Regex.new(k, v) }
  end

  def self.hash
    Redis.current.hgetall(regex_key)
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
    @create_audit ||= AuditEntry.includes(:user).find_by(change_type: "add_regex", key: regex_key)
  end

  def update_audit
    @update_audit ||= AuditEntry.includes(:user)
      .where(change_type: "update_regex", key: regex_key)
      .order("created_at desc").first
  end

  def self.regex_key
    "redirects:regex"
  end

  def regex_key
    Regex.regex_key
  end

  def to_partial_path
    "regex"
  end
end
