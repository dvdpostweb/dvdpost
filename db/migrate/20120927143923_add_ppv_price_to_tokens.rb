class AddPpvPriceToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :is_ppv, :boolean, :default => false
    add_column :tokens, :ppv_price, :float

    add_column :customers, :ppv_ready, :integer
  end

  def self.down
    remove_column :tokens, :is_ppv
    remove_column :tokens, :ppv_price
    
    remove_column :customers, :ppv_ready
  end
end
