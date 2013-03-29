class ShoppingOrder < ActiveRecord::Base
  set_primary_key :shopping_orders_id
  named_scope :ready, :conditions => {:status => 1}
  named_scope :order_id, lambda {|order_id| {:conditions => {:order_id => order_id}}}
  belongs_to :product, :foreign_key => :products_id
  
  def self.price(current_customer, id)
    count = @count = current_customer.shopping_orders.order_id(id).sum(:quantity)
    price = 0
    current_customer.shopping_orders.order_id(id).each do |c|
      price += c.quantity * c.product.price_sale
    end
    reduce = ((price * 0) * 100).round().to_f / 100
    price_reduced = price - reduce
    shipping = ShoppingCart.shipping(count)
    price_ttc = price_reduced + shipping
    {:hs => price, :total => price_ttc, :shipping => shipping, :reduce => reduce, :price_reduced => price_reduced}
  end

end