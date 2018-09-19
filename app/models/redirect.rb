# frozen_string_literal: true

class Redirect
  attr_reader :domain, :to, :cert, :redis

  def initialize(domain, to = nil, cert = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @domain = domain
    @existing_to = redis.get(redirect_key)
    @existing_cert = redis.get(cert_key)
    if @existing_to
      # Update if values were passed in. otherwise return existing
      @to = to || @existing_to
      @cert = cert || @existing_cert
    else
      @to = to
      @cert = cert
    end

    self
  end

  def save
    unless @existing_to
      AuditEntry.create!(change_type: 'add_redirect',
                         key: redirect_key,
                         to_value: to + "using #{cert}",
                         user_id: Thread.current[:user_id])
    end
    if @existing_cert && cert != @existing_cert
      AuditEntry.create!(change_type: 'update_redirect',
                         key: redirect_key,
                         from_value: @existing_cert,
                         to_value: cert,
                         user_id: Thread.current[:user_id])
    end
    redis.set(redirect_key, to)
    redis.set(cert_key, cert)
  end

  def destroy
    redis.del(redirect_key)
    redis.del(cert_key)
    AuditEntry.create!(change_type: 'remove_redirect',
                       key: redirect_key,
                       from_value: to + " using #{cert}",
                       user_id: Thread.current[:user_id])
  end

  def self.all
    keys = Redis.current.keys('domain_redirect:*').collect do |k|
      k.sub('domain_redirect:', '')
    end

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
    @create_audit ||= AuditEntry.includes(:user).find_by(change_type: 'add_redirect', key: redirect_key)
  end

  def update_audit
    @update_audit ||= AuditEntry.includes(:user)
                                .where(change_type: 'update_redirect', key: redirect_key)
                                .order('created_at desc').first
  end

  private

  def redirect_key
    "domain_redirect:#{domain}"
  end

  def cert_key
    "domain:#{domain}"
  end
end
