class AddPpvToStreamingProducts < ActiveRecord::Migration
  def self.up
    add_column :streaming_products, :is_ppv, :boolean
    add_column :streaming_products, :ppv_price, :float
  end

  def self.down
    remove_column :streaming_products, :is_ppv
    remove_column :streaming_products, :ppv_price
  end
end
