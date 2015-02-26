class AddNewPriceToCustomers < ActiveRecord::Migration
  def self.up
    add_column :customers, :alert_price, :boolean, :default => 0
  end

  def self.down
    remove_column :customers, :alert_price
  end
end
