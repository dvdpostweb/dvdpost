class AddSourceIdToVodWishlists < ActiveRecord::Migration
  def self.up
    add_column :vod_wishlists, :source_id, :integer
  end

  def self.down
    remove_column :vod_wishlists, :source_id
  end
end
