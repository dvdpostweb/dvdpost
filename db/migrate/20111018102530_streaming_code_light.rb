class StreamingCodeLight < ActiveRecord::Migration
  def self.up
    add_column :streaming_codes, :white_label, :boolean, :after => :name, :default => 0
  end

  def self.down
    remove_column :streaming_codes, :white_label
  end
end
