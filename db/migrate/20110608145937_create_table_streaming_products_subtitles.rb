class CreateTableStreamingProductsSubtitles < ActiveRecord::Migration
    def self.up
      add_column :streaming_products, :source, 'enum("SOFTLAYER", "ALPHANETWORK")', :default => "SOFTLAYER"
    end

    def self.down
      remove_column :streaming_products, :source
    end
  end
