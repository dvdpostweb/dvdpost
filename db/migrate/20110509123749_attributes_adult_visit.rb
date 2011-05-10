class AttributesAdultVisit < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :number_of_logins_x, :integer, :default => 0
  end

  def self.down
    remove_column :customer_attributes, :number_of_logins_x
  end
end
