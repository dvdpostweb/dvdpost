class ThemesEvent < ActiveRecord::Base
  named_scope :selected, :conditions => {:selected => true}
end
