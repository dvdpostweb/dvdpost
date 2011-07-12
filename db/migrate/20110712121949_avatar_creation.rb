class AvatarCreation < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :avatar, :binary, :limit => 1.megabyte
    add_column :customer_attributes, :avatar_pending, :binary, :limit => 1.megabyte
  end

  def self.down
    remove_column :customer_attributes, :avatar
    remove_column :customer_attributes, :avatar_pending
  end
end
