class CustomersAttributesFormat < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :mobile_format, :boolean
  end

  def self.down
    remove_column :customer_attributes, :mobile_format
  end
end
