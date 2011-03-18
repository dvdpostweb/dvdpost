class ThemesEvent < ActiveRecord::Base
  db_magic :slave => :slave01 if ENV['APP'] == "1"

  named_scope :selected, :conditions => {:selected => true}
  named_scope :selected_beta, :conditions => {:selected => 2}
end
