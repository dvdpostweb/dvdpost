class AddVodCategorie < ActiveRecord::Migration
  def self.up
     add_column :categories, :vod, :boolean, :default => false
   end

   def self.down
     remove_column :categories, :vod
   end
end
