class User < ActiveRecord::Base
  def self.find_or_create_from_auth_hash(auth_hash)
    existing = where(sso_guid: auth_hash.extra.ssoGuid).first
    return existing.apply_auth_hash(auth_hash) if existing

    pending = where(username: auth_hash.extra.user).first
    return pending.apply_auth_hash(auth_hash) if pending

    new.apply_auth_hash(auth_hash)
  end

  def apply_auth_hash(auth_hash)
    self.sso_guid = auth_hash.ssoGuid
    self.username = auth_hash.user
    self.first_name = auth_hash.firstName
    self.last_name = auth_hash.lastName
    save!
    self
  end
end
