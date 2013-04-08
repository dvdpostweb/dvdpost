class AddCountryToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :country, :string, :limit => 3
  end

  def self.down
    remove_column :tokens, :country
  end
end
