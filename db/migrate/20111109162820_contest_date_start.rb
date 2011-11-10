class ContestDateStart < ActiveRecord::Migration
  def self.up
    add_column :contest_name, :available_from, :date
    add_column :contest_name, :winners_count, :integer, :default => 3
    add_column :contest_name, :new, :boolean, :default => true
  end

  def self.down
    remove_column :contest_name, :available_from
    remove_column :contest_name, :winners_count
    remove_column :contest_name, :new
  end
end
