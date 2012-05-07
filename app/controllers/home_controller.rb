class HomeController < ApplicationController
  def index
    respond_to do |format|
      format.html {
        get_data(params[:kind])
      }
      format.js {
        if params[:news_page]
          render :partial => '/home/index/news', :locals => {:news_items => retrieve_news}
        elsif params[:highlight_page]
          get_reviews_data(params[:review_kind], params[:highlight_page], params[:precision])
        elsif params[:selection_page]
          get_selection_week(params[:kind], params[:selection_kind], params[:selection_page])
          render :partial => '/home/index/selection_week', :locals => {:selection_week => @selection}  
        elsif params[:selection_kind]
          get_selection_week(params[:kind], params[:selection_kind], 1)
          render :partial => '/home/index/selection_week', :locals => {:selection_week => @selection}
        elsif params[:close_rating]
          recommendations = retrieve_recommendations(1,{:per_page => 8})
          render :partial => '/home/index/recommendation_box', :locals => {:recommendations => recommendations, :not_rated_product => nil}
        elsif params[:review_kind] 
          get_reviews_data(params[:review_kind], params[:highlight_page], nil)
          if DVDPost.home_review_types[params[:review_kind]] == DVDPost.home_review_types[:best_customer]
            render :partial => 'home/index/reviews', :locals => {:review_kind => @review_kind, :data_all => @data_all, :data_month => @data_month}
          else
            render :partial => 'home/index/reviews', :locals => {:review_kind => @review_kind, :data => @data}
          end
        else
          render :nothing => true
        end
      }
    end
  end

  def indicator_close
    current_customer.inducator_close(params[:status])
    render :nothing => true
  end

  def validation
    if params[:valid] == "1"
      session[:adult] = 1
      begin
        redirect_to session['current_uri']
      rescue => e
        redirect_to root_path(:kind => :adult)
      end
    end
  end

  private
  def get_reviews_data(review_kind, page, precision)
    @review_kind = review_kind
    @precision = precision
    review_kind = DVDPost.home_review_types[@review_kind]
    case review_kind
      when DVDPost.home_review_types[:best_customer]
        if precision == 'all'
          @data = HighlightCustomer.day(0).by_kind('all').ordered.paginate(:per_page => 5, :page => page)
        elsif precision == 'month'
          @data = HighlightCustomer.day(0).by_kind('month').ordered.paginate(:per_page => 10, :page => page)
        else  
          @data_month = HighlightCustomer.day(0).by_kind('month').ordered.paginate(:per_page => 10, :page => page)
          @data_all = HighlightCustomer.day(0).by_kind('all').ordered.paginate(:per_page => 5, :page => page)
        end
      when DVDPost.home_review_types[:best_review]
        @data = HighlightReview.by_language(DVDPost.product_languages[I18n.locale]).ordered.paginate(:per_page => 4, :page => page)
      when DVDPost.home_review_types[:controverse_rate]
        @data = HighlightProduct.day(0).by_kind('controverse').by_language(DVDPost.product_languages[I18n.locale]).ordered.paginate(:per_page => 9, :page => page)
      else
        @data = HighlightProduct.day(0).by_kind('best').by_language(DVDPost.product_languages[I18n.locale]).ordered.paginate(:per_page => 9, :page => page)
    end
  end

  def get_selection_week(kind, selection_kind, selection_page)
    @default = streaming_access? ? :vod : :dvd
    @selection_kind = selection_kind || @default
    @selection_page = selection_page
    if kind == :adult
      @selection = ProductList.theme.by_kind(kind.to_s).by_style(@selection_kind).find_by_home_page(true).products.paginate(:per_page => 2, :page => selection_page)
    else
      @selection = ProductList.theme.by_kind(kind.to_s).by_language(DVDPost.product_languages[I18n.locale]).by_style(@selection_kind).find_by_home_page(true).products.paginate(:per_page => 2, :page => selection_page)
    end
  end

  def get_data(kind)
    if(kind == :adult)
      @newsletter_x = current_customer.customer_attribute.newsletters_x
      @transit_items = current_customer.orders.in_transit.all(:include => :product, :order => 'orders.date_purchased ASC')
      @top_actors = Actor.by_kind(:adult).top.top_ordered.limit(10)
      @trailers_week = Product.all(:joins => :trailers, :conditions => {"products_trailers.focus" => 1, "products_trailers.language_id" => DVDPost.product_languages[I18n.locale]})
      @trailers = Product.all(:joins => :trailers, :conditions => {:products_status => 1, :products_type => DVDPost.product_kinds[:adult], "products_trailers.language_id" => DVDPost.product_languages[I18n.locale]}, :limit => 4, :order => "rand()")
      @top_views = Product.get_top_view(params[:kind], 10, session[:sexuality])
      @recent = Product.get_recent(I18n.locale, params[:kind], 4, session[:sexuality])
      @filter = get_current_filter({})
      @banners = ProductList.theme.by_kind(kind.to_s).by_style(:vod).find_by_home_page(2).products.paginate(:per_page => 3, :page => 1)
      get_selection_week(params[:kind], params[:selection_kind], params[:selection_page]) if kind == :normal || (kind == :adult && streaming_access?)
      if Rails.env == "pre_production"
        @carousel = Landing.by_language_beta(I18n.locale).not_expirated.adult.order(:asc).limit(5)
      else
        @carousel = Landing.by_language(I18n.locale).not_expirated.adult.order(:asc).limit(5)
      end
      not_rated_products = current_customer.not_rated_products(kind)
      @not_rated_product = not_rated_products[rand(not_rated_products.count)]
    else
      if I18n.locale == :fr
        @chronicle = Chronicle.private.selected.first 
      end
      expiration_recommendation_cache()
      @offline_request = current_customer.payment.recovery
      not_rated_products = current_customer.not_rated_products(kind)
      @not_rated_product = not_rated_products[rand(not_rated_products.count)]
      
      
      @transit_items = current_customer.orders.in_transit.all
      begin
        @news_items = retrieve_news
      rescue => e
        logger.error("Failed to retrieve news: #{e.message}")
      end
      @recommendations = retrieve_recommendations(params[:recommendation_page],{:per_page => 12})
      
      if Rails.env == "pre_production"
        @carousel = Landing.by_language_beta(I18n.locale).not_expirated.private.order(:asc).limit(5)
      else
        @carousel = Landing.by_language(I18n.locale).not_expirated.private.order(:asc).limit(5)
      end
      @streaming_available = current_customer.get_all_tokens
      get_selection_week(params[:kind], params[:selection_kind], params[:selection_page])
      get_reviews_data(params[:review_kind], params[:highlight_page], nil)
      @review_count = current_customer.reviews.approved.find(:all,:joins => :product, :conditions => { :products => {:products_type => 'DVD_NORM', :products_status => [-2,0,1]}}).count
      @rating_count = current_customer.ratings.count
      if @theme && @theme.banner_hp == 1
        @theme_hp = @theme
      else
        @theme_hp = theme_actif_hp
      end
      wishlist_size
    end
  end

  def retrieve_news
    fragment_name = "#{I18n.locale.to_s}/home/news"
    news_items = when_fragment_expired fragment_name, 2.hour.from_now do
      begin
        DVDPost.home_page_news
      rescue => e
        logger.error "Homepage news unavailable: #{e.message}"
        expire_fragment(fragment_name)
        nil
      end
    end
    news_items.paginate(:per_page => 3, :page => params[:news_page] || 1) if news_items
  end

  def retrieve_popular
    current_customer.popular(get_current_filter).paginate(:per_page => 8, :page => params[:popular_page])
  end
  
end
