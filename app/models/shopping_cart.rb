class ShoppingCart < ActiveRecord::Base
  set_primary_key :shopping_cart_id
  set_table_name :shopping_cart

  attr_accessor :delete

  alias_attribute :created_at,      :date_added

  before_create :set_defaults

  belongs_to :customer, :foreign_key => :customers_id
  belongs_to :product, :foreign_key => :products_id

  named_scope :ordered, :order => 'shopping_cart_id desc'

  def self.shipping(count)
  	if count == 0
			price = 0
		elsif count <= 2
			price = 2.80
		elsif count <= 12
			price = 6.7
		elsif count <= 24
			price = 12.4
		elsif count <= 37
			price = 19.1
		else
			price = 0.51 * count
		end
  end

  def self.price(current_customer)
      count = current_customer.shopping_carts.sum(:quantity)
      price = 0
      current_customer.shopping_carts.each do |c|
        price += c.quantity * c.product.price_sale
      end
      reduce = ((price * 0) * 100).round().to_f / 100
      price_reduced = price - reduce
      shipping = ShoppingCart.shipping(count)
      price_ttc = price_reduced + shipping
      {:reduce => reduce, :price_reduced => price_reduced, :hs => price, :total => price_ttc, :shipping => shipping}
  end
  
  private
  def set_defaults
    self.created_at = Time.now.localtime.to_s(:db)
    self.quantity = 1
  end
  
end