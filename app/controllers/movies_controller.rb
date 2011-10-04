class MoviesController < ApplicationController
  before_filter :find_movie, :only => [:uninterested, :seen, :awards, :trailer]

  def index
    if ENV['HOST_OK'] == "1"
      if Rails.env == "pre_production"
        @carousel = Landing.by_language_beta(I18n.locale).not_expirated.public.order(:asc).limit(5)
      else
        @carousel = Landing.by_language(I18n.locale).not_expirated.public.order(:asc).limit(5)
      end
      @recommendations = retrieve_recommendations(params[:recommendation_page])
    end
    @filter = get_current_filter({})
    if params[:search] == t('movie.left_column.search')
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
      @popular = nil # current_customer.streaming(filter, {:category_id => params[:category_id]}).paginate(:per_page => 6, :page => params[:popular_streaming_page]) if current_customer
      @category = Category.find(params[:category_id])
      if params[:category_id].to_i == 76
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
        @movies = if params[:view_mode] == 'recommended'
          if(session[:sort] != params[:sort])
            expiration_recommendation_cache()
          end
          session[:sort]=params[:sort] 
          
          retrieve_recommendations(params[:page], { :sort => params[:sort]})
        else
          if session[:sexuality] == 0
            new_params = params.merge(:hetero => 1) 
          else
            new_params = params
          end
          Movie.filter(@filter, new_params)
        end
        @source = WishlistItem.wishlist_source(params, @wishlist_source)
        @category = Category.find(params[:category_id]) if params[:category_id] && !params[:category_id].empty?
        
        
        @jacket_mode = OldProduct.get_jacket_mode(params)
        if(params[:view_mode] == nil && params[:list_id] == nil && params[:category_id] == nil)
          session[:menu_categories] = true
          session[:menu_tops] = false
        end
      end
      format.js {
        if params[:category_id]
          render :partial => 'movies/index/streaming', :locals => {:movies => @popular}
        elsif params[:recommendation_page]
          render :partial => 'home/index/recommendations', :locals => {:movies => retrieve_recommendations(params[:recommendation_page])}  
        end
      }
    end  
  end

  def show
    if params[:kind] == :adult
      @movie = movie.adult_available.find(params[:id])
      @rating_color = :pink
    else
      @movie = Movie.normal_available.find(params[:id])
      @rating_color = :white
    end
    data = @movie.description_data(true)
    @movie_title = data[:title]
    @movie_image = data[:image]
    @movie_description =  data[:description]
    unless request.format.xml?
      @filter = get_current_filter({})
      #@product.views_increment(@product_description)
      @public_url = movie_public_path(@movie)
       if params[:sort] && params[:sort] != Review.sort2[:interesting]
        sort = Review.sort2[params[:sort].to_sym]
      else
        sort =  Review.sort2[:interesting]
      end
     if sort != Review.sort2[:interesting]
       @reviews = @movie.reviews.approved.ordered(sort).by_language(I18n.locale).find(:all, :joins => :movie).paginate(:page => params[:reviews_page], :per_page => 3)
     else
       @reviews = @movie.reviews.approved.by_language(I18n.locale).find(:all, :joins => :movie).paginate(:page => params[:reviews_page], :per_page => 3)
     end
     @reviews_count = movie_reviews_count(@movie)
      
      #product_recommendations = @product.recommendations(params[:kind])
      #@recommendations = product_recommendations.paginate(:page => params[:recommendation_page], :per_page => 6) if product_recommendations
      @recommendations = nil
      @source = (!params[:recommendation].nil? ? params[:recommendation] : @wishlist_source[:elsewhere])
      @token = current_customer ? current_customer.get_token(@movie.imdb_id) : nil
    end
    @collections = Collection.by_size.random
    respond_to do |format|
      format.html do
        @categories = @movie.categories
        @already_seen = current_customer.assigned_products.include?(@product) if current_customer #to do
        
        fragment_name = "cinopsis_#{@movie.id}"
        @cinopsis = when_fragment_expired fragment_name, 1.week.from_now do
           begin
              DVDPost.cinopsis_critics(@movie.imdb_id.to_s)
            rescue => e
              false
              logger.error("Failed to retrieve critic of cinopsis: #{e.message}")
            end
        end
        #@cinopsis = Marshal.load(@cinopsis) if @cinopsis
        if params[:recommendation].to_i == @wishlist_source[:recommendation] || params[:recommendation].to_i == @wishlist_source[:recommendation_product]
          Customer.send_evidence('UserRecClick', @movie.to_param, current_customer, request.remote_ip)
        end
        Customer.send_evidence('ViewItemPage', @movie.to_param, current_customer, request.remote_ip)
      end
      format.js {
        if params[:reviews_page] || params[:sort]
          render :partial => 'movies/show/reviews', :locals => {:movie => @movie, :reviews_count => @reviews_count, :reviews => @reviews}
        elsif params[:recommendation_page]
          render :partial => 'movies/show/recommendations', :locals => { :rating_color => @rating_color }, :object => @recommendations
        end
      }
      format.xml if params[:format] == 'xml'
    end
  end

  def uninterested
    unless current_customer.rated_movies.include?(@movie) || current_customer.seen_movies.include?(@movie) || current_customer.uninterested_movies.include?(@movie)
      @movie.uninterested_customers << current_customer
      Customer.send_evidence('NotInterestedItem', @movie.to_param, current_customer, request.remote_ip)
    end
    respond_to do |format|
      format.html {redirect_to movie_path(:id => @movie.to_param)}
      format.js   {render :partial => 'movies/show/seen_uninterested', :locals => {:movie => @movie}}
    end
  end

  def seen
    @movie.seen_customers << current_customer
    Customer.send_evidence('AlreadySeen', @movie.to_param, current_customer, request.remote_ip)
    respond_to do |format|
      format.html {redirect_to movie_path(:id => @movie.to_param)}
      format.js   {render :partial => 'movies/show/seen_uninterested', :locals => {:movie => @movie}}
    end
  end

  def awards
    data = @movie.description_data(true)
    @movie_description =  data[:description]
    respond_to do |format|
      format.html {render :partial => 'movies/show/awards', :locals => {:description => @movie_description, :size => 'full'}}
      format.js {render :partial => 'movies/show/awards', :locals => {:description => @movie_description, :size => 'full'}}
    end
  end

  def trailer
    trailer = @movie.trailers.by_language(I18n.locale).paginate(:per_page => 1, :page => params[:trailer_page])
    respond_to do |format|
      format.js   {render :partial => 'movies/trailer', :locals => {:trailer => trailer.first, :trailers => trailer}}
      format.html do
        if trailer.first && trailer.first.url
          redirect_to trailer.first.url
        else
          redirect_to movie_path(:id => @movie.to_param)
        end
      end
    end
  end

  def menu_tops
    
    type = params[:type] || 'open'
    if type == 'close'
      session[:menu_tops] = false
    else
      session[:menu_tops] = true
      session[:menu_categories] = false
      
    end
   render :nothing => true
  end

  def menu_categories
    type = params[:type] || 'open'
    if type == 'close'
      session[:menu_categories] = false
    else
      session[:menu_categories] = true
      session[:menu_tops] = false
    end
   render :nothing => true
  end

  def drop_cached
    expire_fragment ("/fr/movies/movie_#{params[:movie_id]}")
    expire_fragment ("/nl/movies/movie_#{params[:movie_id]}")
    expire_fragment ("/en/movies/movie_#{params[:movie_id]}")
    render :nothing => true
  end
private
  def find_movie
    if params[:kind] == :normal
      @movie = Movie.normal_available.find(params[:movie_id])
    else
      @movie = Movie.adult_available.find(params[:movie_id])
    end
  end
end
