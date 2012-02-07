class AddVodStudio < ActiveRecord::Migration
  def self.up
    add_column :studio, :vod, :boolean, :default => false
  end

  def self.down
    remove_column :studio, :vod
  end
end
