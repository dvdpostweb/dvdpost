class AddCreditsToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :credits, :integer
  end

  def self.down
    remove_column :tokens, :credits
  end
end
