class AddSourceIdToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :source_id, :integer
  end

  def self.down
    remove_column :tokens, :source_id
  end
end
