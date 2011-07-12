class ThemeEventsSelections < ActiveRecord::Migration
  def self.up
    create_table :themes_events_selections do |t|
      t.string :name
      t.timestamps
    end
    rename_column :themes_events, :selected, :themes_events_selection_id
  end

  def self.down
    drop_table :themes_events_selections
    rename_column :themes_events, :themes_events_selection_id, :selected
  end
end
