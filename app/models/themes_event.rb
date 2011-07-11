class ThemesEvent < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']

  named_scope :selected, :conditions => {:selected => 1}
  named_scope :selected_beta, :conditions => {:selected => 2}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => kind.to_s}}}
  named_scope :old_beta, {:conditions => {:selected => [3,2]}}
  named_scope :old, {:conditions => {:selected => [3]}}
  

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true
end
