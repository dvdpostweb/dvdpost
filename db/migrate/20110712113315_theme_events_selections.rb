class ThemeEventsSelections < ActiveRecord::Migration
  def self.up
    create_table :themes_events_selections do |t|
      t.string :name
      t.timestamps
    end
    add_column :themes_events, :themes_events_selection_id, :integer
  end

  def self.down
    drop_table :themes_events_selections
    remove_column :themes_events, :themes_events_selection_id
  end
end
