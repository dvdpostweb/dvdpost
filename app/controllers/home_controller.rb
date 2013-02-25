class HomeController < ApplicationController
  def index
    @tokens = current_customer.get_all_tokens_id(params[:kind]) if current_customer
    respond_to do |format|
      format.html {
        if mobile_request?
          get_data_mobile(params[:kind])
        else
          get_data(params[:kind])
        end
      }
      format.js {
        if params[:news_page]
          get_news
          render :partial => '/home/index/news', :locals => {:news_items => @news_items, :news_page => @news_page, :news_nb_page => @news_nb_page}
        elsif params[:highlight_page]
          get_reviews_data(params[:review_kind], params[:highlight_page], params[:precision])
        elsif params[:action_popup]
          render :partial => '/home/index/product_action', :locals => {:item => Product.find(params[:product_id])}
        elsif params[:selection_page]
          get_selection_week(params[:kind], params[:selection_kind], params[:selection_page])
          render :partial => "/home/index/selection_week#{params[:kind] == :adult ? '_adult' : ''}", :locals => {:selection_week => @selection, :selection_page => @selection_page, :selection_nb_page => @selection_nb_page}
        elsif params[:selection_kind]
          get_selection_week(params[:kind], params[:selection_kind], 1)
          render :partial => "/home/index/selection_week#{params[:kind] == :adult ? '_adult' : ''}", :locals => {:selection_week => @selection, :selection_page => @selection_page, :selection_nb_page => @selection_nb_page}
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

  def error_email
    recipient = 'gs@dvdpost.be'
    subject = 'error page'
    message = params[:page]
    message += " #{current_customer.id}" if current_customer  
    Emailer.deliver_send(recipient, subject, message)
    flash[:notice] = t '.tx', :default => 'Merci de votre contribution'
    redirect_to root_path()
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
        @data = HighlightReview.by_language(DVDPost.product_languages[I18n.locale]).ordered.paginate(:per_page => 3, :page => page)
      when DVDPost.home_review_types[:controverse_rate]
        @data = HighlightProduct.day(0).by_kind('controverse').by_language(DVDPost.product_languages[I18n.locale]).ordered.find(:all, :include => :product).paginate(:per_page => 8, :page => page)
      else
        @data = HighlightProduct.day(0).by_kind('best').by_language(DVDPost.product_languages[I18n.locale]).ordered.find(:all, :include => :product).paginate(:per_page => 9, :page => page)
    end
  end

  def get_selection_week(kind, selection_kind, selection_page)
    @default = streaming_access? ? :vod : :dvd
    @selection_kind = selection_kind || @default
    @selection_page = selection_page || 1
    selection = when_fragment_expired "#{Rails.env}_selection_new2_#{kind}_#{selection_page}_#{@selection_kind}_#{DVDPost.product_languages[I18n.locale]}", 1.hour.from_now.localtime do
      if kind == :adult
        sql = ProductList.theme.by_kind(kind.to_s).by_style(@selection_kind).find_by_home_page(true).products.paginate(:per_page => 2, :page => selection_page)
      else
        sql = ProductList.theme.by_kind(kind.to_s).by_language(DVDPost.product_languages[I18n.locale]).by_style(@selection_kind).find_by_home_page(true).products.paginate(:per_page => 3, :page => selection_page)
      end
      Marshal.dump(sql)
    end
    Product.class
    @selection = Marshal.load(selection)
    @selection_nb_page = @selection.total_pages
  end

  def get_data_mobile(kind)
    get_selection_week(params[:kind], params[:selection_kind], params[:selection_page]) if kind == :normal || (kind == :adult && streaming_access?)
    @top_searches = Search.count(:group => 'name', :order => 'count_all desc', :limit => 20, :conditions => ["kind = ? and created_at >= ? ", DVDPost.search_kinds[kind], 1.week.ago.localtime])
    filter = get_current_filter
    @new_movies = Product.filter(filter, params.merge(:sort => 'production_year_all', :country_id => 0, :limit => 6))
  end

  def get_data(kind)
    status = Rails.env == 'production' ? 'ONLINE' : ['ONLINE','TEST']
    news_serial = when_fragment_expired "#{Rails.env}_news_hp_#{params[:kind]}_#{status}_#{DVDPost.product_languages[I18n.locale]}", 1.hour.from_now.localtime do
      if params[:kind] == :adult
        Marshal.dump(News.ordered.by_kind(params[:kind]).private.first(:joins =>:contents, :conditions => { :news_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}}))
      else
        Marshal.dump(News.ordered.by_kind(params[:kind]).private.all(:limit => 4, :joins =>:contents, :conditions => { :news_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}}))
      end
    end
    @newsletter = PublicNewsletter.new(params[:public_newsletter])
    News.class
    @news = Marshal.load(news_serial)
    landing_serial = when_fragment_expired "#{Rails.env}_landings_hp2_#{I18n.locale}_#{params[:promo]}_#{params[:kind]}_#{ENV['HOST_OK']}", 30.minutes.from_now.localtime do
      if Rails.env == "pre_production"
        pre_sql = Landing.by_language_beta(I18n.locale).not_expirated
      else
        pre_sql = Landing.by_language(I18n.locale).not_expirated
      end
      
      case params[:kind] 
        when :adult 
          sql = pre_sql.adult.order(:asc).limit(5) 
        when :normal
          if ENV['HOST_OK'] == "0"
            sql = pre_sql.private.order(:asc).limit(6)
          else
            sql = pre_sql.public_test.order(:asc).limit(6)
          end
      end
      Marshal.dump(sql)
    end
    Landing.new
    @carousel = Marshal.load(landing_serial)
    
    if(kind == :adult)
      if ENV['HOST_OK'] == "0"
        @newsletter_x = current_customer.customer_attribute.newsletters_x
        @transit_items = current_customer.orders.in_transit.all(:include => :product, :order => 'orders.date_purchased ASC')
        not_rated_products = current_customer.not_rated_products(kind)
        @not_rated_product = not_rated_products[rand(not_rated_products.count)]
        trailer_limit = 2
      else
        trailer_limit = 3
      end
      @top_actors = Actor.by_kind(:adult).top.top_ordered.limit(10)
      @trailers_week = Product.all(:joins => :trailers, :conditions => ["products_trailers.focus > 0 and products_trailers.language_id = ? ", DVDPost.product_languages[I18n.locale]], :limit => trailer_limit, :order => "products_trailers.focus desc")
      @trailers = Product.all(:joins => :trailers, :include => :actors, :conditions => {:products_status => 1, :products_type => DVDPost.product_kinds[:adult], "products_trailers.language_id" => DVDPost.product_languages[I18n.locale]}, :limit => 4, :order => "rand()")
      @top_views = Product.get_top_view(params[:kind], 10, session[:sexuality], session[:country_id])
      @recent = Product.get_recent(I18n.locale, params[:kind], 4, session[:sexuality])
      @filter = get_current_filter({})
      @banners = ProductList.theme.by_kind(kind.to_s).by_style(:vod).find_by_home_page(2).products.paginate(:per_page => 3, :page => 1)
      get_selection_week(params[:kind], params[:selection_kind], params[:selection_page]) if kind == :normal || (kind == :adult && streaming_access?)
      @themes = ThemesEvent.hp.selected.by_kind(params[:kind]).ordered.limit(2)
    else
      if I18n.locale != :en
        chronicle_serial = when_fragment_expired "#{Rails.env}_chronicle_hp2_#{status}_#{DVDPost.product_languages[I18n.locale]}", 1.hour.from_now.localtime do
          Marshal.dump(Chronicle.private.ordered.all(:joins =>:contents, :limit => 2, :conditions => { :chronicle_contents => {:language_id => DVDPost.product_languages[I18n.locale], :status => status}}))
        end
        Chronicle.class
        @chronicles = Marshal.load(chronicle_serial)
      end
      get_news
      #@streaming_available = current_customer.get_all_tokens
      get_selection_week(params[:kind], params[:selection_kind], params[:selection_page])
      get_reviews_data(params[:review_kind], params[:highlight_page], nil)
      #to do
      if ENV['HOST_OK'] == "0"
        @review_count = current_customer.reviews.approved.find(:all,:joins => :product, :conditions => { :products => {:products_type => 'DVD_NORM', :products_status => [-2,0,1]}}).count
        @rating_count = current_customer.ratings.count
        wishlist_size
        @offline_request = current_customer.payment.recovery
        @transit_items = current_customer.orders.in_transit.all
        @theme = ThemesEvent.selected.hp.by_kind(params[:kind]).ordered.first
        @theme_month = true
        @theme = ThemesEvent.selected.hp.by_kind(params[:kind]).first
        if @theme.too_old
          @theme = ThemesEvent.old.hp.by_kind(params[:kind]).ordered_rand.first
          @theme_month = false
        end
        expiration_recommendation_cache()
        @recommendations = retrieve_recommendations(params[:recommendation_page],{:per_page => 8, :kind => params[:kind], :language => DVDPost.product_languages[I18n.locale.to_s]})
      end
    end
  end

  def get_news
    begin
      @news_page = params[:news_page] || 1
      @news_items = retrieve_news(@news_page)
      @news_nb_page = @news_items.total_pages
    rescue => e
      logger.error("Failed to retrieve news: #{e.message}")
    end
    
  end
  def retrieve_news(news_page)
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
    news_items.paginate(:per_page => 3, :page => news_page) if news_items
  end

  def retrieve_popular
    current_customer.popular(get_current_filter).paginate(:per_page => 8, :page => params[:popular_page])
  end
  
end
