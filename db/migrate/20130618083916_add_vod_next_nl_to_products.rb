class AddVodNextNlToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :vod_next_nl, :boolean, :after => 'vod_next_lux', :default => 0
  end

  def self.down
    remove_column :products, :vod_next_nl
  end
end
