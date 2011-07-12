class CreateNicknames < ActiveRecord::Migration
  def self.up
    #drop_table :nicknames
    add_column :customer_attributes, :nickname, :string
    add_column :customer_attributes, :nickname_pending, :string
    
  end

  def self.down
    add_column :customers, :nickname, :string
    create_table :nicknames do |t|
      t.references :customer
      t.boolean :status
      t.string :nickname
      t.timestamps
    end
    add_index :nicknames, :customer_id
    add_column :customer_attributes, :nickname, :string
    add_column :customer_attributes, :nickname_pending, :string
    
  end
end
