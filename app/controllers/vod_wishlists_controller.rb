class VodWishlistsController < ApplicationController
  def index
    @tokens = current_customer.get_all_tokens_id(params[:kind])
    kind = params[:kind] || :normal
    if params[:transit_or_history] == "history"
      @history_list = current_customer.get_all_tokens(params[:kind], :old, params[:page])
    else
      @token_list = current_customer.get_all_tokens(params[:kind])
    end
    @list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}, :streaming_products], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["streaming_products.available = 1 and streaming_products.status = 'online_test_ok' and products_status != -1 and products_type = :type and ((available_from <= :now and expire_at >= :now) or (available_backcatalogue_from <= :now and expire_backcatalogue_at >= :now)) and country = :country", {:type => DVDPost.product_kinds[params[:kind]], :now => Time.now().localtime.to_s(:db), :country => Product.country_short_name(session[:country_id])}])
    if session[:country_id] = 161
      country_filter = "vod_next_nl = 1 and"
    elsif session[:country_id] = 131
      country_filter = "vod_next_lux = 1 and"
    else
      country_filter = "vod_next = 1 and"
    end
    @soon_list = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["#{country_filter} products_status != -1 and products_type = :type", {:type => DVDPost.product_kinds[params[:kind]], :media => DVDPost.product_types[:vod]}])
    @display_vod = !mobile_request? ? current_customer.customer_attribute.display_vod : 0
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
    item = current_customer.vod_wishlists.find_by_imdb_id(params[:vod_wishlist][:imdb_id])
    @submit_id = params[:vod_wishlist][:submit_id]
    @product = Product.find(params[:vod_wishlist][:product_id])
    unless item
      
      current_customer.vod_wishlists.create(:imdb_id => params[:vod_wishlist][:imdb_id], :source_id => params[:source])
    end
    
    Customer.send_evidence('addToWishlistVOD', @product.to_param, current_customer, request, {:response_id => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser), :rule => params[:source]})
    respond_to do |format|
      format.html {redirect_back_or  wishlist_path}
      format.js   do
      end
    end
  end

  def display_vod
    value = params[:value] 
    current_customer.display_vod(value)
    redirect_to vod_wishlists_path(:transit_or_history => params[:transit_or_history])
  end
  private
  def redirect_back_or(path)
    redirect_to :back
  rescue ::ActionController::RedirectBackError
    redirect_to path
  end
end
