class ProductsController < ApplicationController
  before_filter :find_product, :only => [:uninterested, :seen, :awards, :trailer, :show]

  def index
    if ENV['HOST_OK'] == "1"
      if params[:kind] == :adult
        if Rails.env == "pre_production"
          @carousel = Landing.by_language_beta(I18n.locale).not_expirated.adult.order(:asc).limit(5)
        else
          @carousel = Landing.by_language(I18n.locale).not_expirated.adult.order(:asc).limit(5)
        end
      else
        if Rails.env == "pre_production"
          @carousel = Landing.by_language_beta(I18n.locale).not_expirated.public.order(:asc).limit(5)
        else
          @carousel = Landing.by_language(I18n.locale).not_expirated.public.order(:asc).limit(5)
        end
      end
      @recommendations = retrieve_recommendations(params[:recommendation_page], {:per_page => 8}) if params[:kind] == :normal
    end
    @filter = get_current_filter({})
    if params[:search] == t('products.left_column.search')
      params.delete(:search)
    else
      if params[:search]
        sub_str = params[:search].to_s
        params[:search] = sub_str.gsub(/\//,'').gsub(/"/,' ').gsub(/\(/,' ').gsub(/\)/,' ')
      end
    end
    if params['actor_id']
      @actor = Actor.find(params['actor_id'])
      params['actor_id'] = @actor.id
    end
    if params['director_id']
      director = Director.find(params['director_id'])
      params['director_id'] = director.id
    end
    
    
    
    if params[:category_id]
      filter = get_current_filter
      if params[:category_id] && streaming_access? && (params[:view_mode] != "streaming" && params[:filter] != "vod")
        @popular = current_customer.streaming(filter, {:category_id => params[:category_id]}).paginate(:per_page => 6, :page => params[:popular_streaming_page]) if current_customer
      else
        @popular = nil
      end
      
      if params[:category_id].to_i == 76 && current_customer
        current_customer.customer_attribute.update_attribute(:sexuality, 1)
        session[:sexuality] = 1
      end
    end
    if params[:sort].nil?
      params[:sort] = 'normal'
    end
    @rating_color = params[:kind] == :adult ? :pink : :white
    @countries = ProductCountry.visible.order
    @collections = Category.by_size.random
    respond_to do |format|
      format.html do
        if params[:search] && !params[:search].empty?
          @exact_products = Product.filter(@filter, params.merge(:exact => 1)) 
          #@actors = Actor.search_clean(params[:search], params[:kind])
        end
        unless params[:type] == 'actors'
        @products = if params[:view_mode] == 'recommended'
          if(session[:sort] != params[:sort])
            expiration_recommendation_cache()
          end
          session[:sort]=params[:sort] 
          
          retrieve_recommendations(params[:page], params.merge(:per_page => 20))
        else
          if session[:sexuality] == 0
            new_params = params.merge(:hetero => 1) 
          else
            new_params = params
          end
          if @exact_products && @exact_products.size > 0
            Product.filter(@filter, new_params, @exact_products)
          else
            Product.filter(@filter, new_params)
          end
        end
        end 
        @source = WishlistItem.wishlist_source(params, @wishlist_source)
        @jacket_mode = Product.get_jacket_mode(params)
      end
      
      format.js {
        if params[:category_id]
          render :partial => 'products/index/streaming', :locals => {:products => @popular}
        elsif params[:recommendation_page]
          render :partial => 'home/index/recommendations', :locals => {:products => retrieve_recommendations(params[:recommendation_page], {:per_page => 8})}  
        end
      }
    end  
  end

  def show
    user_agent = UserAgent.parse(request.user_agent)
    @shop_list = ProductList.shop.status.by_language(DVDPost.product_languages[I18n.locale]).first
    data = @product.description_data(true)
    @product_title = data[:title]
    @product_image = data[:image]
    @product_description =  data[:description]
    unless request.format.xml?
      @filter = get_current_filter({})
      @product.views_increment(@product_description)
      @public_url = product_public_path(@product)
       if params[:sort]
        sort = Review.sort2[params[:sort].to_sym]
        @review_sort = params[:sort].to_sym
        cookies[:review_sort] = { :value => params[:sort], :expires => 1.year.from_now }
      else
        if cookies[:review_sort]
          sort =  Review.sort2[cookies[:review_sort].to_sym]
          @review_sort = cookies[:review_sort].to_sym
        else
          sort =  Review.sort2[:date]
          @review_sort = :date
        end
      end
      if @product.imdb_id == 0
        if sort != Review.sort2[:interesting]
          @reviews = @product.reviews.approved.ordered(sort).by_language(I18n.locale).paginate(:page => params[:reviews_page], :per_page => 3)
        else
          @reviews = @product.reviews.approved.by_language(I18n.locale).paginate(:page => params[:reviews_page], :per_page => 3)
        end
      else  
        if sort != Review.sort2[:interesting]
          @reviews = Review.by_imdb_id(@product.imdb_id).approved.ordered(sort).by_language(I18n.locale).find(:all, :joins => :product).paginate(:page => params[:reviews_page], :per_page => 3)
        else
          @reviews = Review.by_imdb_id(@product.imdb_id).approved.by_language(I18n.locale).find(:all, :joins => :product).paginate(:page => params[:reviews_page], :per_page => 3)
        end
      end
      @reviews_count = product_reviews_count(@product)
      
      product_recommendations = @product.recommendations(params[:kind])
      @recommendations = product_recommendations.paginate(:page => params[:recommendation_page], :per_page => 6) if product_recommendations
      if !params[:recommendation].nil?
        @source = params[:recommendation]
      elsif params[:source]
        @source = params[:source]
      else
        @source = @wishlist_source[:elsewhere]
      end
      @token = current_customer ? current_customer.get_token(@product.imdb_id) : nil
    end
    @collections = Collection.by_size.random
    respond_to do |format|
      
      format.html do
        @categories = @product.categories
        @already_seen = current_customer.assigned_products.include?(@product) if current_customer
        
        #fragment_name = "cinopsis_#{@product.id}"
        #@cinopsis = when_fragment_expired fragment_name, 1.week.from_now do
        #   begin
        #      DVDPost.cinopsis_critics(@product.imdb_id.to_s)
        #    rescue => e
        #      false
        #      logger.error("Failed to retrieve critic of cinopsis: #{e.message}")
        #    end
        #end
        
        @cinopsis = nil
        #@cinopsis = Marshal.load(@cinopsis) if @cinopsis
        if  @source.to_i == @wishlist_source[:recommendation] ||  @source.to_i == @wishlist_source[:recommendation_product]
          Customer.send_evidence('UserRecClick', @product.to_param, current_customer, request.remote_ip)
        end
        Customer.send_evidence('ViewItemPage', @product.to_param, current_customer, request.remote_ip)
      end
      format.js {
        if params[:reviews_page] || params[:sort]
          render :partial => 'products/show/reviews', :locals => {:product => @product, :reviews_count => @reviews_count, :reviews => @reviews}
        elsif params[:recommendation_page]
          render :partial => 'products/show/recommendations', :locals => { :rating_color => @rating_color }, :object => @recommendations
        end
      }
      format.mobile do
      end
    end
  end

  def uninterested
    unless current_customer.rated_products.include?(@product) || current_customer.seen_products.include?(@product) || current_customer.uninterested_products.include?(@product)
      @product.uninterested_customers << current_customer
      Customer.send_evidence('NotInterestedItem', @product.to_param, current_customer, request.remote_ip)
    end
    respond_to do |format|
      format.html {redirect_to product_path(:id => @product.to_param, :source => params[:source])}
      format.js   {render :partial => 'products/show/seen_uninterested', :locals => {:product => @product}}
    end
  end

  def seen
    @product.seen_customers << current_customer
    Customer.send_evidence('AlreadySeen', @product.to_param, current_customer, request.remote_ip)
    respond_to do |format|
      format.html {redirect_to product_path(:id => @product.to_param, :source => params[:source])}
      format.js   {render :partial => 'products/show/seen_uninterested', :locals => {:product => @product}}
    end
  end

  def awards
    data = @product.description_data(true)
    @product_description =  data[:description]
    respond_to do |format|
      format.js {render :partial => 'products/show/awards', :locals => {:product => @product, :size => 'full'}}
    end
  end

  def trailer
    trailer = @product.trailers.by_language(I18n.locale).paginate(:per_page => 1, :page => params[:trailer_page])
    respond_to do |format|
      format.js   {
        if trailer.first
          render :partial => 'products/trailer', :locals => {:trailer => trailer.first, :trailers => trailer}
        else
          render :text => 'error'
        end
      }
      format.html do
        if trailer.first && trailer.first.url
          redirect_to trailer.first.url
        else
          redirect_to product_path(:id => @product.to_param, :source => params[:source])
        end
      end
    end
  end

  def drop_cached
    expire_fragment ("/fr/products/product_1_1_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_1_1_#{params[:product_id]}")
    expire_fragment ("/en/products/product_1_1_#{params[:product_id]}")
    expire_fragment ("/fr/products/product_1_0_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_1_0_#{params[:product_id]}")
    expire_fragment ("/en/products/product_1_0_#{params[:product_id]}")

    expire_fragment ("/fr/products/product_0_1_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_0_1_#{params[:product_id]}")
    expire_fragment ("/en/products/product_0_1_#{params[:product_id]}")
    expire_fragment ("/fr/products/product_0_0_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_0_0_#{params[:product_id]}")
    expire_fragment ("/en/products/product_0_0_#{params[:product_id]}")
    render :nothing => true
  end
private
  def find_product
    begin 
      if params[:id]
        id = params[:id]
      else
        id = params[:product_id]
      end
      if Rails.env == "production"
        if params[:kind] == :adult
          @product = Product.adult_available.find(id)
          @rating_color = :pink
        else
          @product = Product.normal_available.find(id)
          @rating_color = :white
        end
      else
        if params[:kind] == :adult
          @product = Product.find(id)
          @rating_color = :pink
        else
          @product = Product.find(id)
          @rating_color = :white
        end
      end
    rescue ActiveRecord::RecordNotFound
      msg = "product not found"
      logger.error(msg)
      flash[:notice] = msg
      redirect_to products_path
    end
  end
end
