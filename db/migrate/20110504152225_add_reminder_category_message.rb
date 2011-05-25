class AddReminderCategoryMessage < ActiveRecord::Migration
  def self.up
    add_column :category_tickets, :reminder, :boolean, :default => 0
    add_column :themes, :active, :boolean, :default => 1
  end

  def self.down
    remove_column :category_tickets, :reminder
    remove_column :themes, :active
    
  end
end
