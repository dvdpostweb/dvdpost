class VodWishlistsController < ApplicationController
  def index
    @token_list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}, :streaming_products, :tokens], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["streaming_products.available_from < :time and streaming_products.expire_at > :time and streaming_products.status = 'online_test_ok' and products_status != -1 and products_type = :type and tokens.updated_at > :start and tokens.updated_at < :end and tokens.customer_id = :customer_id", {:time => Time.now, :type => DVDPost.product_kinds[params[:kind]], :start => 2.week.ago.localtime, :end => Time.now, :customer_id => current_customer.to_param}])
    @all_list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}, :streaming_products], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["streaming_products.available_from < :time and streaming_products.expire_at > :time and streaming_products.status = 'online_test_ok' and products_status != -1 and products_type = :type", {:time => Time.now, :type => DVDPost.product_kinds[params[:kind]], :start => 2.week.ago.localtime, :end => Time.now}])
    @list = @all_list - @token_list
    @soon_list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["products_media = :media and products_next = 1 and products_status != -1 and products_type = :type", {:time => Time.now, :type => DVDPost.product_kinds[params[:kind]], :start => 2.week.ago.localtime, :end => Time.now, :media => DVDPost.product_types[:vod]}])
    @soon_list = @soon_list - @list
    @display_vod = current_customer.customer_attribute.display_vod
  end

  def destroy
    VodWishlist.find(params[:id]).destroy
    @div = params[:div]
    respond_to do |format|
      format.html {redirect_back_or  wishlist_path}
      format.js   do
      end
    end
  end

  def create
    item = VodWishlist.find_by_imdb_id(params[:vod_wishlist][:imdb_id])
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
