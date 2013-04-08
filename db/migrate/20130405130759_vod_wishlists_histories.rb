class VodWishlistsHistories < ActiveRecord::Migration
  def self.up
    create_table :vod_wishlists_histories do |t|
      t.integer :customer_id
      t.integer :imdb_id
      t.integer :source_id
      t.datetime :added_at
      t.timestamps
    end
    add_index :vod_wishlists_histories, :customer_id
    add_index :vod_wishlists_histories, :imdb_id
  end

  def self.down
    drop_table :vod_wishlists_histories
  end
end
