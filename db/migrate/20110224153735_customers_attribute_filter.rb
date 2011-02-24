class CustomersAttributeFilter < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :filter_id, :integer
  end

  def self.down
    remove_column :customer_attributes, :filter_id
  end
end
