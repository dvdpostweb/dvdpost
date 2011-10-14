class CreateStreamingCodes < ActiveRecord::Migration
  def self.up
    create_table :streaming_codes do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :streaming_codes
  end
end
