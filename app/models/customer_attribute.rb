class CustomerAttribute < ActiveRecord::Base
  has_one :customer, :foreign_key => :customers_id, :primary_key => :customer_id
  
  validates_length_of :nickname_pending, :minimum => 2, :unless => :update_nickname
  validates_length_of :nickname_pending, :maximum => 20, :unless => :update_nickname

  def update_nickname
    nickname_pending.nil?
  end
end