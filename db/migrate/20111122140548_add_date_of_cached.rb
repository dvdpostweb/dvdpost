class AddDateOfCached < ActiveRecord::Migration
  def self.up
    add_column :products, :cached_at, :datetime, :after => 'products_last_modified'
  end

  def self.down
    remove_column :products, :cached_at
  end
end
