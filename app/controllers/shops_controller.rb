class ShopsController < ApplicationController
  def show
    @list = ProductList.shop.by_language(DVDPost.product_languages[I18n.locale])
  end
end