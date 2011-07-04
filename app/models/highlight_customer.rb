class HighlightCustomer < ActiveRecord::Base

  belongs_to :customer
  named_scope :day, lambda {|day| {:conditions => {:day => day}}}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => kind}}}
end