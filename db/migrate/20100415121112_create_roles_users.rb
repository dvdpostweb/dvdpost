class CreateRolesUsers < ActiveRecord::Migration
  def self.up
    create_table :roles_users, :id => false do |t|
      t.references :role, :user
      t.timestamps
    end

    add_index :roles_users, :role_id
    add_index :roles_users, :user_id
  end

  def self.down
    remove_index :roles_users, :role_id
    remove_index :roles_users, :user_id

    drop_table :roles_users
  end
end
