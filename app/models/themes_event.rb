class ThemesEvent < ActiveRecord::Base
  named_scope :selected, :conditions => {:selected => true}
  named_scope :selected_beta, :conditions => {:selected => 2}
end
