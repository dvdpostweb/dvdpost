class AddColumnAttributesDisplayVod < ActiveRecord::Migration
  def self.up
     add_column :customer_attributes, :display_vod, :integer, :default => 0
  end

  def self.down
    remove_column :customer_attributes, :display_vod
  end
end
