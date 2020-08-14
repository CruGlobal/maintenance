# frozen_string_literal: true

class Redirect
  attr_reader :domain, :to, :redis

  def initialize(domain, to = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @domain = domain
    @existing_to = redis.get(redirect_key)
    if @existing_to
      # Update if values were passed in. otherwise return existing
      @to = to || @existing_to
    else
      @to = to
    end

    self
  end

  def save
    unless @existing_to
      AuditEntry.create!(change_type: "add_redirect",
                         key: redirect_key,
                         to_value: to,
                         user_id: Thread.current[:user_id])
    end
    redis.set(redirect_key, to)
  end

  def destroy
    redis.del(redirect_key)
    AuditEntry.create!(change_type: "remove_redirect",
                       key: redirect_key,
                       from_value: to,
                       user_id: Thread.current[:user_id])
  end

  def self.all
    keys = Redis.current.keys("domain_redirect:*").collect { |k|
      k.sub("domain_redirect:", "")
    }

    keys.sort.collect { |k| Redirect.new(k) }
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
    @create_audit ||= AuditEntry.includes(:user).find_by(change_type: "add_redirect", key: redirect_key)
  end

  def update_audit
    @update_audit ||= AuditEntry.includes(:user)
      .where(change_type: "update_redirect", key: redirect_key)
      .order("created_at desc").first
  end

  private

  def redirect_key
    "domain_redirect:#{domain}"
  end
end
