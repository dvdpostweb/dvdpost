class ThemesEvent < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  named_scope :selected, :conditions => {:themes_events_selection_id => 1}
  named_scope :selected_beta, :conditions => {:themes_events_selection_id => 2}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => kind.to_s}}}
  named_scope :old, :conditions => {:themes_events_selection_id => 3}
  
end
