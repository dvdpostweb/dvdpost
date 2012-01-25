class ShoppingOrder < ActiveRecord::Base
  set_primary_key :shopping_orders_id
  named_scope :ready, :conditions => {:status => 1}
  named_scope :order_id, lambda {|order_id| {:conditions => {:order_id => order_id}}}
  belongs_to :product, :foreign_key => :products_id
end