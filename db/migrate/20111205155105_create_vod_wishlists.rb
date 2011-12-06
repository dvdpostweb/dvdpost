class CreateVodWishlists < ActiveRecord::Migration
  def self.up
    create_table :vod_wishlists do |t|
      t.integer :customer_id
      t.integer :imdb_id
      t.timestamps
    end
    add_index :vod_wishlists, :customer_id
    add_index :vod_wishlists, :imdb_id
    
  end

  def self.down
    drop_table :vod_wishlists
  end
end
