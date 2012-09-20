class CreatePublicNewsletterProducts < ActiveRecord::Migration
  def self.up
    create_table :public_newsletter_products do |t|
      t.integer :public_newsletter_id
      t.integer :product_id
      t.timestamps
    end
  end

  def self.down
    drop_table :public_newsletter_products
  end
end

