class AddColumnSourceStreaming < ActiveRecord::Migration
  def self.up
    create_table :streaming_products_subtitles do |t|
      t.string :streaming_product_id
      t.string :subtitle_id
    end
    add_index :streaming_products_subtitles, [:subtitle_id, :streaming_product_id]
  end

  def self.down
    drop_table :streaming_products_subtitles
  end
end
