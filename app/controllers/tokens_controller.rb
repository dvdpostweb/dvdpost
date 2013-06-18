class TokensController < ApplicationController
  def new
    @product = Product.find(params[:product_id])
    all = Product.find_all_by_imdb_id(params[:imdb_id])
    @product_in_wishlist = current_customer.wishlist_items.find_all_by_product_id(all)
    @streaming_free = streaming_free(@product)
    @streaming = StreamingProduct.available.country(Product.country_short_name(session[:country_id])).find_by_imdb_id(@product.imdb_id)
    @vod_create_token = General.find_by_CodeType('VOD_CREATE_TOKEN').value
    @vod_disable = General.find_by_CodeType('VOD_ONLINE').value
    respond_to do |format|
      format.html
      format.js   { render :layout => false }
    end
  end
end