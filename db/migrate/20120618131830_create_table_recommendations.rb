class CreateTableRecommendations < ActiveRecord::Migration
  def self.up
    create_table :recommendations do |t|
      t.references :product
      t.integer :rank
      t.integer :recommendation_id
      t.timestamps
    end
    add_index :recommendations, :product_id
  end

  def self.down
    remove_index :recommendations, :product_id
    drop_table :recommendations
  end
end
