class AddColumnActorOfTheWeek < ActiveRecord::Migration
    def self.up
      add_column :actors, :focus, :boolean, :default => 0
    end

    def self.down
      remove_column :actors, :focus
    end
  end
