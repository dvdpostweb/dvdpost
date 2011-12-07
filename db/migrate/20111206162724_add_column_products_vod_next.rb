class AddColumnProductsVodNext < ActiveRecord::Migration
  def self.up
     add_column :products, :vod_next, :boolean, :after => 'products_next', :default => 0
  end

  def self.down
    remove_column :products, :vod_next
  end
end
