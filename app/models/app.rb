class App
  attr_reader :name, :redis

  def initialize(name)
    @name = name
    @redis = redis || Redis.current
    raise Index::NoredisInstance unless @redis
  end

  def dependencies
    redis.smembers(dependencies_key) || []
  end

  def dependencies=(deps)
    dependencies.each { |dep| remove_dependency(dep) }

    deps.each do |dep|
      add_dependency(dep) if dep.present? and dep != name
    end
  end

  def add_dependency(dep)
    redis.sadd(dependencies_key, dep)
  end

  def remove_dependency(dep)
    redis.srem(dependencies_key, dep)
  end

  def maintenance=(maint)
    if maint == '1'
      redis.set(maintenance_key, true)
      update_dependencies
    else
      redis.del(maintenance_key)
    end
  end

  def maintenance
    redis.get(maintenance_key)
  end

  private

  def maintenance_key
    "maintenance:#{name}:maintenance"
  end

  def dependencies_key
    "maintenance:#{name}:dependencies"
  end

  def update_dependencies
    dependencies.each do |dep|
      App.new(dep).maintenance = '1'
    end
  end


end
