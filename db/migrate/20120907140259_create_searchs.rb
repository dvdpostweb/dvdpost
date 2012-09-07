class CreateSearchs < ActiveRecord::Migration
  def self.up
    create_table :searches do |t|
      t.string :name
      t.column :kind, "ENUM('normal', 'adult')"
      t.timestamps
    end
    add_index :searches, :name
  end

  def self.down
    drop_table :searches
  end
end
