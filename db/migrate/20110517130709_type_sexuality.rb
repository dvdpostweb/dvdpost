class TypeSexuality < ActiveRecord::Migration
  def self.up
    add_column :customer_attributes, :sexuality, :integer, :default => 0
  end

  def self.down
  remove_column :customer_attributes, :sexuality
  end
end

