class CreationNicknames < ActiveRecord::Migration
  def self.up
    create_table :nicknames do |t|
      t.references :customer
      t.boolean :status
      t.string :nickname
      t.timestamps
    end
    add_index :nicknames, :customer_id
  end

  def self.down
    remove_index :nicknames, :customer_id

    drop_table :nicknames
  end
end
