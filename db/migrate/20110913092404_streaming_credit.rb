class StreamingCredit < ActiveRecord::Migration
  def self.up
    add_column :streaming_products, :credits, :int, :default => 1, :null => false
  end

  def self.down
    remove_column :streaming_products, :credits
  end
end
