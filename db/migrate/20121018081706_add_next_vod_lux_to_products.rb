class AddNextVodLuxToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :vod_next_lux, :boolean, :after => 'vod_next', :default => 0
  end

  def self.down
    remove_column :products, :vod_next_lux
  end
end
