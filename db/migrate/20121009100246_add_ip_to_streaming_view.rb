class AddIpToStreamingView < ActiveRecord::Migration
  def self.up
    add_column :streaming_viewing_histories, :ip, :string, :default => nil
  end

  def self.down
    remove_column :streaming_viewing_histories, :ip
  end
end
