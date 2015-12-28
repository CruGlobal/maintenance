class AddHasAccessToUser < ActiveRecord::Migration
  def change
    add_column :users, :has_access, :boolean
  end
end
