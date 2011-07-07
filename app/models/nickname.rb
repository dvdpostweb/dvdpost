class Nickname < ActiveRecord::Base
  validates_length_of :nickname, :minimum => 2
  validates_length_of :nickname, :maximum => 20

  named_scope :waiting, :conditions => {:status => 0}
  
end