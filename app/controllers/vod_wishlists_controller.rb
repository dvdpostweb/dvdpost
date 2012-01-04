class VodWishlistsController < ApplicationController
  def index
    kind = params[:kind] || :normal
    @token_list = current_customer.get_all_tokens
    @list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}, :streaming_products], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["streaming_products.available_from < :time and streaming_products.expire_at > :time and streaming_products.status = 'online_test_ok' and products_status != -1 and products_type = :type", {:time => Time.now, :type => DVDPost.product_kinds[params[:kind]]}])
    @soon_list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["vod_next = 1 and products_status != -1 and products_type = :type", {:type => DVDPost.product_kinds[params[:kind]], :media => DVDPost.product_types[:vod]}])
    @soon_list = @soon_list - @list
    @display_vod = current_customer.customer_attribute.display_vod
    @wishlist_items_count = current_customer.wishlist_items.current.available.by_kind(kind).ordered.find(:all, :joins => {:product => :descriptions}, :conditions => {"products_description.language_id" => DVDPost.product_languages[I18n.locale.to_s]}).count
  end

  def destroy
    VodWishlist.find(params[:id]).destroy
    @product = Product.find(params[:vod_wishlist][:product_id]) if params[:vod_wishlist] && params[:vod_wishlist][:product_id]
    @submit_id = params[:vod_wishlist][:submit_id] if params[:vod_wishlist] && params[:vod_wishlist][:submit_id]
    @div = params[:div] if params[:div]
    respond_to do |format|
      format.html {redirect_back_or  wishlist_path}
      format.js   do
      end
    end
  end

  def create
    item = VodWishlist.find_by_imdb_id(params[:vod_wishlist][:imdb_id])
    @submit_id = params[:vod_wishlist][:submit_id]
    @product = Product.find(params[:vod_wishlist][:product_id])
    unless item
      current_customer.vod_wishlists.create(:imdb_id => params[:vod_wishlist][:imdb_id])
    end
    respond_to do |format|
      format.html {redirect_back_or  wishlist_path}
      format.js   do
      end
    end
  end

  def display_vod
    value = params[:value] 
    current_customer.display_vod(value)
    redirect_to vod_wishlists_path 
  end
  private
  def redirect_back_or(path)
    redirect_to :back
  rescue ::ActionController::RedirectBackError
    redirect_to path
  end
end
