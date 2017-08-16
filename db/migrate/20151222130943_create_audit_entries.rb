class CreateAuditEntries < ActiveRecord::Migration[4.2]
  def change
    create_table :audit_entries do |t|
      t.string :change_type
      t.string :key
      t.text :from_value
      t.text :to_value
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
