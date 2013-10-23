class WishlistItemsController < ApplicationController
  def index
    @tokens = current_customer.get_all_tokens_id(params[:kind])
    kind = params[:kind] || :normal
    @vod_count = current_customer.vod_wishlists.find(:all, :joins => [{:products => :descriptions}, :streaming_products], :group => 'vod_wishlists.imdb_id', :order =>'products_description.products_name', :conditions => ["streaming_products.available = 1 and streaming_products.status = 'online_test_ok' and products_status != -1 and products_type = :type and ((available_from <= :now and expire_at >= :now) or (available_backcatalogue_from <= :now and expire_backcatalogue_at >= :now)) and country = :country", {:type => DVDPost.product_kinds[params[:kind]], :now => Time.now().localtime.to_s(:db), :country => Product.country_short_name(session[:country_id])}]).count
    
    @wishlist_items_current = current_customer.wishlist_items.current.available.by_kind(kind).ordered.find(:all, :joins => {:product => :descriptions}, :conditions => {:products_description => { :language_id => DVDPost.product_languages[I18n.locale.to_s]}})
    @wishlist_items_future = current_customer.wishlist_items.future.available.by_kind(kind).ordered.find(:all, :joins => {:product => :descriptions}, :conditions => {:products_description => { :language_id => DVDPost.product_languages[I18n.locale.to_s]}})
    @wishlist_items_not_available = current_customer.wishlist_items.not_available.available.by_kind(kind).ordered.find(:all, :joins => {:product => :descriptions}, :conditions => {:products_description => { :language_id => DVDPost.product_languages[I18n.locale.to_s]}})
    
    @transit_or_history = params[:transit_or_history] || 'transit'
    if @transit_or_history == 'history'
      @history_items = current_customer.orders(:include => [:status, :product]).in_history.ordered.paginate(:page => params['history_page'], :per_page => 20)
      @count = current_customer.orders.in_history.count
      locals = {:transit_items => nil, :history_items => @history_items, :history_count => @count}
    else
      @transit_items = current_customer.orders.in_transit.ordered.all(:include => [:product, :status])
      locals = {:transit_items => @transit_items, :history_items => nil, :history_count => nil}
    end
    respond_to do |format|
      format.html
      format.js   {render :partial => 'wishlist_items/index/transit_history_list', :locals => locals.merge(:wishlist_items_count => @wishlist_items_current.count)}
    end
  end

  def start
    @hide_menu = true
    @popular = current_customer.popular(get_current_filter, {:country_id => session[:country_id]}).paginate(:page => params[:popular_page], :per_page => 8)
    wishlist_size()
    respond_to do |format|
      format.html do
        session[:popular_page] = params[:popular_page] || 1
        @wishlist = current_customer.wishlist_items.current.available.ordered_by_id.by_kind(:normal).include_products.limit(8)
      end      
      format.js {
        session[:popular_page] = params[:popular_page]
        render :partial => 'wishlist_items/popular', :locals => {:products => @popular, :id => :popular_tab}
      }
    end
  end

  def new
    session[:back_url] = request.env['HTTP_REFERER']
    @product = Product.both_available.find(params[:product_id])
    if @product.imdb_id > 0 && (@product.products_series_id == 0 || @product.serie.saga?)
      @products = Product.both_available.ordered_media.find_all_by_imdb_id(@product.imdb_id)
    else
      @products = Product.both_available.find_all_by_products_id(params[:product_id])
    end
    @tokens = current_customer.get_all_tokens_id(params[:kind], @product.imdb_id)
    
    @submit_id = params[:submit_id]
    @text = params[:text]
    
    @wishlist_item = WishlistItem.new
    respond_to do |format|
      format.html
      format.js do
        render :layout => false
      end
    end
  end

  def create
    if params[:type] == 'classic'
      @source = params[:wishlist_item][:wishlist_source_id]
      @submit_id = params[:submit_id]
      @type = params[:type]
      @text = params[:text].to_sym
      @load_color = params[:load_color].to_sym if params[:load_color]
      if @source.to_i == 3
        expiration_recommendation_cache
      end
    end
    
    if params[:wishlist_item][:wishlist_source_id].to_i == 0
      WishlistItem.notify_hoptoad("add to wishlist without source url => #{request.request_uri} params : #{params.inspect} referer : #{request.env['HTTP_REFERER'] if request.env['HTTP_REFERER']}")
    end
    
    begin
      if params[:add_all_from_series] || (params[:all_movies] && params[:all_movies].to_i == 1)
        product = Product.both_available.find(params[:wishlist_item][:product_id])
        good = product.good_language?(DVDPost.product_languages[I18n.locale])
        if good
          item1 = Product.by_serie(product.series_id).by_media(product.media).with_languages(DVDPost.product_languages[I18n.locale])
          if item1.count > 0
            item2 = Product.by_serie(product.series_id).by_media(product.media).with_subtitles(DVDPost.product_languages[I18n.locale]).exclude_products_id(item1.collect(&:products_id).join(', '))
            res = item1 + item2
          else
            item2 = Product.by_serie(product.series_id).by_media(product.media).with_subtitles(DVDPost.product_languages[I18n.locale])
            res = item2
          end
          
        else
          language = product.languages.preferred_serie.collect(&:languages_id).join(', ')
          sub = product.subtitles.preferred_serie.collect(&:undertitles_id).join(', ')
          res = Product.by_serie(product.series_id).by_media(product.media).with_languages(language).with_subtitles(sub)
        end
        res.collect do |product|
          create_wishlist_item(params[:wishlist_item].merge({:product_id => product.to_param}))
        end
        @wishlist_item = current_customer.wishlist_items.by_product(product)
        flash[:notice] = t('wishlist_items.index.product_serie_add', :title => product.title, :priority => DVDPost.wishlist_priorities.invert[params[:wishlist_item][:priority].to_i])
      else
        @wishlist_item = create_wishlist_item(params[:wishlist_item])
        flash[:notice] = t('wishlist_items.index.product_add', :title => @wishlist_item.product.title, :priority => DVDPost.wishlist_priorities.invert[@wishlist_item.priority])
      end
      respond_to do |format|
        format.html {redirect_back_or wishlist_path}
        format.js do
          if params[:type] == 'classic'
            @product = @wishlist_item.product
          else
            filter = get_current_filter
            wishlist_size()
            @product_id = params[:wishlist_item][:product_id]
            popular_page = session[:popular_page] || 1
            @popular = current_customer.popular(filter, {:country_id => session[:country_id]}).paginate(:page => popular_page, :per_page => 8)
            if popular_page.to_i > 1 && @popular.size == 0
              session[:popular_page] = popular_page.to_i - 1
              @popular = current_customer.popular(filter, {:country_id => session[:country_id]}).paginate(:page => session[:popular_page], :per_page => 8)
            end
            @wishlist = current_customer.wishlist_items.current.available.ordered_by_id.by_kind(:normal).include_products.limit(8)
          end
        end
      end
      
    rescue Exception => e
      if @wishlist_item && product
        flash[:error] = t('wishlist_items.index.product_not_add', :title => product.title)
        redirect_to product
      else
        flash[:error] = t('wishlist_items.index.product_error_unexpected')
        respond_to do |format|
          format.html {redirect_to wishlist_path}
          format.js {}
        end
      end
    end
  end

  def update
    begin
      @wishlist_item = WishlistItem.find(params[:id])
      @wishlist_item.update_attributes(params[:wishlist_item])
      Customer.send_evidence('UpdateWishlistItem', params[:id], current_customer, request, {:response_id => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser), :rule => params[:source]}, {:priority => params[:wishlist_item][:priority]}) if params[:wishlist_item]
      respond_to do |format|
        format.js {
          @form_id = "form_#{params[:id]}"
        }
      end
    end
  end

  def destroy
      @wishlist_item = WishlistItem.destroy(params[:id])
      Customer.send_evidence('RemoveFromWishlist', params[:id], current_customer, request, {:response_id => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser), :rule => params[:source]})
      respond_to do |format|
        format.html {redirect_back_or  wishlist_path}
        format.js   do
          if params[:popular]
            wishlist_size()
            filter = get_current_filter
            @product_id = params[:product_id]
            popular_page = session[:popular_page] || 1
            @popular = current_customer.popular(filter, {:country_id => session[:country_id]}).paginate(:page => popular_page, :per_page => 8)
            if popular_page.to_i > 1 && @popular.size == 0
              session[:popular_page] = popular_page.to_i - 1
              @popular = current_customer.popular(filter, {:country_id => session[:country_id]}).paginate(:page => session[:popular_page], :per_page => 8)
            end
            @wishlist = current_customer.wishlist_items.current.available.ordered_by_id.by_kind(:normal).include_products.limit(8)
          elsif params[:list]  && params[:list].to_i == 1
            @product = @wishlist_item.product
            @source = params[:source]
            @type = 'list'
            @text = params[:text].to_sym
            @submit_id = params[:submit_id]
            @form_id = params[:form_id]
            
            @load_color = params[:load_color].to_sym if params[:load_color]
            flash[:notice] = t('wishlist_items.index.product_remove', :title => @wishlist_item.product.title)
          elsif params[:list]  && params[:list].to_i == 2
            @type = 'wishlist'
            @div = params[:div]
          else  
              render :status => :ok, :nothing => true
          end
        end
      end
  end

  def bluray_owner
    if params[:value]
      current_customer.bluray_owner(params[:value])
    else
      current_customer.bluray_owner(true)
    end
    render :nothing => true  
  end


  private
  def create_wishlist_item(params)
    response_id = params.delete :response_id
    wishlist_item = WishlistItem.new(params)
    wishlist_item.customer = current_customer
    wishlist_item.save
    Customer.send_evidence('AddToWishlist', params[:product_id], current_customer, request, {:responseid => response_id, :segment1 => params[:wishlist_source_id], :formFactor => format_text(@browser) , :rule => params[:wishlist_source_id]}, {:priority => params[:priority]})
    wishlist_item
  end

  def redirect_back_or(path)
    if !session[:back_url].nil?
      url = session[:back_url]
      session[:back_url] = nil
      redirect_to url
    else
      begin
        redirect_to :back
      rescue Exception => e
        redirect_to path
      end
    end
  end
end
