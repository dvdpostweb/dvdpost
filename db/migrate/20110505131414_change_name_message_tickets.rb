class ChangeNameMessageTickets < ActiveRecord::Migration
  def self.up
    rename_column :message_tickets, :read, :is_read
    rename_column :message_tickets, :variables, :data
    
  end

  def self.down
    rename_column :message_tickets, :is_read, :read
    rename_column :message_tickets, :data, :variables
    
  end
end
