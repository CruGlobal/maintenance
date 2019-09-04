# frozen_string_literal: true

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
    (dependencies.to_set - deps.to_set).each { |dep| remove_dependency(dep) }

    (deps.to_set - dependencies.to_set).each do |dep|
      add_dependency(dep) if dep.present? && dep != name
    end
  end

  def add_dependency(dep)
    redis.sadd(dependencies_key, dep)
    AuditEntry.create!(change_type: "add_dependency",
                       key: dependencies_key,
                       to_value: dep,
                       user_id: Thread.current[:user_id])
  end

  def remove_dependency(dep)
    redis.srem(dependencies_key, dep)
    AuditEntry.create!(change_type: "remove_dependency",
                       key: dependencies_key,
                       from_value: dep,
                       user_id: Thread.current[:user_id])
  end

  def maintenance=(maint)
    if maint == "1"
      redis.set(maintenance_key, true)
      update_dependencies
      AuditEntry.create!(change_type: "set_maintenance",
                         key: maintenance_key,
                         from_value: false,
                         to_value: true,
                         user_id: Thread.current[:user_id])
    else
      redis.del(maintenance_key)
      AuditEntry.create!(change_type: "set_maintenance",
                         key: maintenance_key,
                         from_value: true,
                         to_value: false,
                         user_id: Thread.current[:user_id])
    end
  end

  def maintenance
    redis.get(maintenance_key)
  end

  def whitelist
    redis.smembers(whitelist_key) || []
  end

  def whitelist=(domains)
    # Remove existing domains missing from input
    (whitelist.to_set - domains.to_set).each { |domain| remove_domain(domain) }

    # Add new domains missing from existing domains
    (domains.to_set - whitelist.to_set).each do |domain|
      add_domain(domain) if domain.present?
    end
  end

  def add_domain(domain)
    redis.sadd(whitelist_key, domain)
    AuditEntry.create!(change_type: "add_domain",
                       key: whitelist_key,
                       to_value: domain,
                       user_id: Thread.current[:user_id])
  end

  def remove_domain(domain)
    redis.srem(whitelist_key, domain)
    AuditEntry.create!(change_type: "remove_domain",
                       key: whitelist_key,
                       from_value: domain,
                       user_id: Thread.current[:user_id])
  end

  private

  def maintenance_key
    "maintenance:#{name}:maintenance"
  end

  def dependencies_key
    "maintenance:#{name}:dependencies"
  end

  def whitelist_key
    "maintenance:#{name}:whitelist"
  end

  def update_dependencies
    dependencies.each do |dep|
      App.new(dep).maintenance = "1"
    end
  end
end
