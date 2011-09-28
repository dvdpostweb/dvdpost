class StreamingFreeType < ActiveRecord::Migration
  def self.up
    add_column :streaming_products_free, :kind, 'enum("BETA_TEST", "ALL")'
  end

  def self.down
    remove_column :streaming_products_free, :kind
  end
end
