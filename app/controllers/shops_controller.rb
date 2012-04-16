class ShopsController < ApplicationController
  def show
    list_base = Rails.env == "production" ? ProductList.shop.status : ProductList.shop
    list = list_base.by_language(DVDPost.product_languages[I18n.locale]).first
    @items = list ? list.products : nil 
    cart = current_customer.shopping_carts.ordered
    @cart_count = cart.sum(:quantity)
    @cart = cart.paginate(:per_page => 3, :page => 1)
    price_data = ShoppingCart.price(current_customer)
    @total = price_data[:total]
    @shipping = price_data[:shipping]
  end
end