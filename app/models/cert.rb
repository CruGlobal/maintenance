class Cert
  attr_reader :name, :cert, :key, :redis

  def initialize(name, cert = nil, key = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @name = name
    existing = redis.hmget(cert_key, 'cert', 'key')
    if existing.compact.present?
      @cert = existing[0]
      @key = existing[1]
    else
      @cert = cert
      @key = key
    end

    self
  end

  def save
    redis.hmset(cert_key, 'cert', cert, 'key', key)
  end

  def destroy
    redis.del(cert_key)
  end

  def self.all
    Thread.current['all_certs'] ||= Redis.current.keys('cert:*').collect do |k|
      k.sub('cert:', '')
    end.sort.collect { |k| Cert.new(k) }
  end

  private

  def cert_key
    "cert:#{name}"
  end
end
