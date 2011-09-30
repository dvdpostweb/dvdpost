class CustomersAttributeOnlyVod < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :only_vod, :boolean, :default => 0
    add_column :customer_attributes, :credits_already_recieved, :boolean, :default => 0
  end

  def self.down
    remove_column :customer_attributes, :only_vod
    remove_column :customer_attributes, :credits_already_recieved
  end
end
