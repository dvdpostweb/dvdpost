class ModificationMail < ActiveRecord::Migration
  def self.up
    rename_column :message_tickets, :message, :variables
  end

  def self.down
    rename_column :message_tickets, :variables, :message
  end
end
