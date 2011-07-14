class CustomerAttribute < ActiveRecord::Base
  has_one :customer, :foreign_key => :customers_id, :primary_key => :customer_id
  
  validates_length_of :nickname_pending, :minimum => 2, :on => :update
  validates_length_of :nickname_pending, :maximum => 20, :on => :update
end