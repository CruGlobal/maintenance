class Redirect
  attr_reader :domain, :to, :cert, :redis

  def initialize(domain, to = nil, cert = nil)
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis

    @domain = domain
    existing_to = redis.get(redirect_key)
    if existing_to
      # Update if values were passed in. otherwise return existing
      @to = to || existing_to
      @cert = cert || redis.get(cert_key)
    else
      @to = to
      @cert = cert
    end

    self
  end

  def save
    redis.set(redirect_key, to)
    redis.set(cert_key, cert)
  end

  def destroy
    redis.del(redirect_key)
    redis.del(cert_key)
  end

  def self.all
    Redis.current.keys('redirect:*').collect do |k|
      k.sub('redirect:', '')
    end.sort.collect { |k| Redirect.new(k) }
  end

  private

  def redirect_key
    "redirect:#{domain}"
  end

  def cert_key
    "domain:#{domain}"
  end
end
