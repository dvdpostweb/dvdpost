class NewPricing < ActiveRecord::Migration
  def self.up
    add_column :products_abo, :qty_dvd_max, :integer, :default => 0, :after => :qty_credit
    add_column :customers, :customers_abo_dvd_remain, :integer, :default => 0, :after => :customers_abo_dvd_credit
  end

  def self.down
    remove_column :products_abo, :qty_dvd_max
    remove_column :customers, :customers_abo_dvd_remain
    
  end
end
