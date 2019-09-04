# frozen_string_literal: true

class Vanity
  attr_reader :path, :target, :redis

  def initialize(path, target = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @path = path
    @existing_target = redis.get(vanity_key)
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
      AuditEntry.create!(change_type: "add_vanity",
                         key: vanity_key,
                         to_value: target,
                         user_id: Thread.current[:user_id])
    end
    if @existing_target && target != @existing_target
      AuditEntry.create!(change_type: "update_vanity",
                         key: vanity_key,
                         from_value: @existing_target,
                         to_value: target,
                         user_id: Thread.current[:user_id])
    end
    redis.set(vanity_key, target)
  end

  def destroy
    redis.del(vanity_key)
    AuditEntry.create!(change_type: "remove_vanity",
                       key: vanity_key,
                       from_value: target,
                       user_id: Thread.current[:user_id])
  end

  def self.all
    keys = Redis.current.keys("redirect:*").collect { |k|
      k.sub("redirect:", "")
    }

    keys.sort.collect { |k| Vanity.new(k) }
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
    @create_audit ||= AuditEntry.includes(:user).find_by(change_type: "add_vanity", key: vanity_key)
  end

  def update_audit
    @update_audit ||= AuditEntry.includes(:user)
      .where(change_type: "update_vanity", key: vanity_key)
      .order("created_at desc").first
  end

  def vanity_key
    "redirect:#{path}"
  end

  def to_partial_path
    "vanity"
  end
end
