class CreateSelectionKind < ActiveRecord::Migration
  def self.up
    add_column :product_lists, :restriction, 'enum("NORMAL", "ADULT")', :default => 'normal', :after => :kind, :null => false
  end

  def self.down
    remove_column :product_lists, :restriction
  end
end
