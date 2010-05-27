class DropUsersTable < ActiveRecord::Migration
  def self.up
    remove_index :users, [:id, :confirmation_token]
    remove_index :users, :email
    remove_index :users, :remember_token
    drop_table :users
  end

  def self.down
    create_table(:users) do |t|
      t.string   :email
      t.string   :encrypted_password, :limit => 128
      t.string   :salt,               :limit => 128
      t.string   :confirmation_token, :limit => 128
      t.string   :remember_token,     :limit => 128
      t.boolean  :email_confirmed, :default => false, :null => false
      t.timestamps
    end

    add_index :users, [:id, :confirmation_token]
    add_index :users, :email
    add_index :users, :remember_token
  end
end
