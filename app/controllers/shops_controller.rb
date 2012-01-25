class ShopsController < ApplicationController
  def show
    @list = ProductList.shop
  end
end