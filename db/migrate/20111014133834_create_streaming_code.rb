class CreateStreamingCode < ActiveRecord::Migration
  def self.up
    
    create_table :streaming_codes do |t|
      t.string :name
      t.integer :activation_group_id
      t.date :expiration_at
      t.datetime :used_at
      t.timestamps
    end
    add_index :streaming_codes, :id
    add_index :streaming_codes, :name
    
  end

  def self.down
    drop_table :streaming_codes
  end
end
