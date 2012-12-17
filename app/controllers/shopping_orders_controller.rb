class ShoppingOrdersController < ApplicationController
  def show
    @items = current_customer.shopping_orders.find_all_by_order_id(params[:id])
    @count = current_customer.shopping_orders.order_id(params[:id]).sum(:quantity)
    @articles_count = current_customer.shopping_orders.order_id(params[:id]).count
    price_data = ShoppingOrder.price(current_customer, params[:id])
    @total = price_data[:total]
    @hs = price_data[:hs]
    @shipping = price_data[:shipping]
    @reduce = price_data[:reduce]
    @price_reduced = price_data[:price_reduced]
    @type = :orders
  end
end
