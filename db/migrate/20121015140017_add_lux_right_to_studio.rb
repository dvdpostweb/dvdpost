class AddLuxRightToStudio < ActiveRecord::Migration
  def self.up
    add_column :studio, :vod_lux, :boolean, :default => false
  end

  def self.down
    remove_column :studio, :vod_lux
  end
end
