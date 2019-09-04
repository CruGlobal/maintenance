# frozen_string_literal: true

class Cert
  attr_reader :name, :cert, :key, :redis

  def initialize(name, cert = nil, key = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @name = name
    @existing = redis.hmget(cert_key, "cert", "key")
    if @existing.compact.present?
      @cert = cert || @existing[0]
      @key = key || @existing[1]
    else
      @cert = cert
      @key = key
    end

    self
  end

  def save
    if cert != @existing[0]
      AuditEntry.create!(change_type: @existing[0] ? "update_cert" : "add_cert",
                         key: cert_key + ":cert",
                         from_value: @existing[0],
                         to_value: cert,
                         user_id: Thread.current[:user_id])
    end
    if key != @existing[1]
      AuditEntry.create!(change_type: @existing[1] ? "update_key" : "add_key",
                         key: cert_key + ":key",
                         from_value: "redacted",
                         to_value: "redacted",
                         user_id: Thread.current[:user_id])
    end
    redis.hmset(cert_key, "cert", cert, "key", key)
  end

  def destroy
    redis.del(cert_key)
    AuditEntry.create!(change_type: "delete_cert",
                       key: cert_key,
                       user_id: Thread.current[:user_id])
  end

  def self.all
    keys = Redis.current.keys("cert:*").collect { |k|
      k.sub("cert:", "")
    }

    keys.sort.collect { |k| Cert.new(k) }
  end

  private

  def cert_key
    "cert:#{name}"
  end
end
