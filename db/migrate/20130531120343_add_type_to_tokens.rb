class AddTypeToTokens < ActiveRecord::Migration
  def self.up
    add_column :tokens, :kind, 'enum("NORMAL", "PPV", "SVOD_ADULT")', :default => 'NORMAL'
  end

  def self.down
    remove_column :tokens, :kind
  end
end
