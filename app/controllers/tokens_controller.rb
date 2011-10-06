class TokensController < ApplicationController
  def new
    @movie = Movie.find(params[:movie_id])
    #to do
    all = Movie.find(51).products.first
    @product_in_wishlist = current_customer.wishlist_items.find_all_by_product_id(all)
    @streaming_free = streaming_free(@movie)
    @streaming = StreamingProduct.find_by_imdb_id(@movie.imdb_id)
    
    render :layout => false
  end
end