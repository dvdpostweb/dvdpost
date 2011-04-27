class CustomerMailCopy < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :mail_copy, :boolean, :default => 1
  end

  def self.down
    remove_column :customer_attributes, :mail_copy
  end
end
