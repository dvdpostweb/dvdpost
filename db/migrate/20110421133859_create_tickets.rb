class CreateTickets < ActiveRecord::Migration
  def self.up
    create_table :category_tickets do |t|
      t.string :name
      t.timestamps
    end
    create_table :tickets do |t|
      t.references :customer
      t.string :title
      t.integer :category_ticket_id
      t.boolean :remove, :default => false
      t.timestamps
    end

    create_table :message_tickets do |t|
      t.integer :user_id
      t.integer :mail_id
      t.integer :ticket_id
      t.text :message
      t.boolean :read, :default => false
      t.timestamps
    end
    
  end

  def self.down
    drop_table :category_tickets
    drop_table :tickets
    drop_table :message_tickets
  end
end
