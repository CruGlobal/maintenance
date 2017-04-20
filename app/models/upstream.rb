class Upstream
  attr_reader :path, :target, :redis

  def initialize(path, target = nil)
    @redis = redis || Redis.current
    fail Index::NoredisInstance unless @redis

    @path = path
    @existing_target = redis.get(upstream_key)
    if @existing_target
      # Update if values were passed in. otherwise return existing
      @target = target || @existing_target
    else
      @target = target
    end

    self
  end

  def save
    unless @existing_target
      AuditEntry.create!(change_type: 'add_upstream',
                         key: upstream_key,
                         to_value: target,
                         user_id: Thread.current[:user_id])
    end
    if @existing_target && target != @existing_target
      AuditEntry.create!(change_type: 'update_upstream',
                         key: upstream_key,
                         from_value: @existing_target,
                         to_value: target,
                         user_id: Thread.current[:user_id])
    end
    redis.set(upstream_key, target)
  end

  def destroy
    redis.del(upstream_key)
    AuditEntry.create!(change_type: 'remove_upstream',
                       key: upstream_key,
                       from_value: target,
                       user_id: Thread.current[:user_id])
  end

  def self.all
    keys = Redis.current.keys('upstreams:*').collect do |k|
      k.sub('upstreams:', '')
    end

    keys.sort.collect { |k| Upstream.new(k) }
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
    @create_audit ||= AuditEntry.includes(:user).find_by(change_type: 'add_upstream', key: upstream_key)
  end

  def update_audit
    @update_audit ||= AuditEntry.includes(:user)
                          .where(change_type: 'update_upstream', key: upstream_key)
                          .order('created_at desc').first
  end

  def upstream_key
    "upstreams:#{path}"
  end

  def to_partial_path
    'upstream'
  end
end
