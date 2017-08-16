class AddHasAccessToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :has_access, :boolean
  end
end
