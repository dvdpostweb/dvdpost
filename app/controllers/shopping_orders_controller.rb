class ShoppingOrdersController < ApplicationController
  def show
    @orders = current_customer.shopping_orders.find_all_by_order_id(params[:id])
    @count = current_customer.shopping_orders.order_id(params[:id]).sum(:quantity)
  end
end