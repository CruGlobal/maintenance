class CreateCerts < ActiveRecord::Migration[4.2]
  def change
    create_table :certs do |t|
      t.timestamps null: false
    end
  end
end
