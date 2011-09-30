class ReviewsController < ApplicationController

  def index
    if params[:sort]
      sort = Review.sort[params[:sort].to_sym]
    else
      sort = Review.sort[:date]
    end
    if params[:kind] == :adult
      @reviews = Review.by_customer_id(params[:customer_id]).approved.ordered(sort).find(:all,:joins => :movie, :conditions => { :movies => {:status => [-2,0,1]}}).paginate(:page => params[:page], :per_page => 10)
      @reviews_count = Review.by_customer_id(params[:customer_id]).approved.find(:all,:joins => :movie, :conditions => { :movies => {:status => [-2,0,1]}}).count
    else
      @reviews = Review.by_customer_id(params[:customer_id]).approved.ordered(sort).find(:all,:joins => :movie, :conditions => { :movies => {:movie_kind_id => DVDPost.movie_kinds[params[:kind]], :status => [-2,0,1]}}).paginate(:page => params[:page], :per_page => 10)
      @reviews_count = Review.by_customer_id(params[:customer_id]).approved.find(:all,:joins => :movie, :conditions => { :movies => {:movie_kind_id => DVDPost.movie_kinds[params[:kind]], :status => [-2,0,1]}}).count
    end
    
    @customer = Customer.find(params[:customer_id])
    @source = @wishlist_source[:reviews]
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def show
    @review = Review.find(params[:id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def new
    @movie = Movie.both_available.find(params[:movie_id])
    @review = Review.new(:movie_id => params[:movie_id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    begin
      @movie = Movie.find(params[:movie_id])
      old_product_id = @movie.products.first.old_product_id
      @product = OldProduct.find(old_product_id)
      
      review = @product.old_reviews.build(params[:review])
      review.customer = current_customer
      review.languages_id = DVDPost.product_languages[I18n.locale]
      review.save
      unless current_customer.has_rated?(@movie)
        @movie.ratings.create(:customer => current_customer, :value => params[:review][:rating])
        current_customer.seen_products << @product if 1==0 
        Customer.send_evidence('Rating', params[:movie_id], current_customer, request.remote_ip, {:rating => params[:review][:rating]})
      end
      flash[:notice] = t('products.show.review.review_save')
    rescue Exception => e  
      flash[:notice] = t('products.show.review.review_not_save')
    end
    redirect_to movie_path(:id => @movie.to_param)
  end
end
