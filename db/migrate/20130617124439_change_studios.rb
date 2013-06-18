class ChangeStudios < ActiveRecord::Migration
  def self.up
    rename_column :studio, :vod, :vod_be
    add_column :studio, :vod_nl, :boolean, :default => false
  end

  def self.down
    rename_column :studio, :vod_be, :vod
    remove_column :studio, :vod_nl
  end
end
