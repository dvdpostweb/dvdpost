class CacheProductDescription < ActiveRecord::Migration
  def self.up
      add_column :products_description, :cached_name, :string
    end

    def self.down
      remove_column :products_description, :cached_name
    end
end
