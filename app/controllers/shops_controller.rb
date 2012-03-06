class ShopsController < ApplicationController
  def show
    list = ProductList.shop.by_language(DVDPost.product_languages[I18n.locale]).first
    @items = list ? list.products : nil 
    cart = current_customer.shopping_carts
    @cart_count = cart.count
    @cart = cart.paginate(:per_page => 3, :page => 1)
    @count = current_customer.shopping_carts.sum(:quantity)
    @shipping = ShoppingCart.shipping(@count)
    @price = 0
    current_customer.shopping_carts.each do |c|
      @price += c.quantity * c.product.price_sale
    end
    @price += @shipping
  end
end