class ReviewsController < ApplicationController

  def index
    @tokens = current_customer.get_all_tokens_id(params[:kind]) if current_customer
    if params[:sort]
      sort = Review.sort[params[:sort].to_sym]
    else
      sort = Review.sort[:date]
    end
    if params[:kind] == :adult
      @reviews = Review.by_customer_id(params[:customer_id]).approved.ordered(sort).find(:all, :include => :product, :conditions => { :products => {:products_status => [-2,0,1]}}).paginate(:page => params[:page], :per_page => 10)
      @reviews_count = @reviews.total_entries
    else
      @reviews = Review.by_customer_id(params[:customer_id]).approved.ordered(sort).find(:all, :include => :product, :conditions => { :products => {:products_type => DVDPost.product_kinds[params[:kind]], :products_status => [-2,0,1]}}).paginate(:page => params[:page], :per_page => 10)
      @reviews_count = @reviews.total_entries
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
    @tokens = current_customer.get_all_tokens_id(params[:kind], @review.product.imdb_id) if current_customer
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def new
    @product = Product.both_available.find(params[:product_id])
    @review = Review.new(:imdb_id => @product.imdb_id)
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    begin
      @product = Product.both_available.find(params[:product_id])
      params[:review][:text] = params[:review][:text].gsub(/\n/, '').gsub(/\r/, '').gsub(//, "'").gsub(//,'"').gsub(//,'"').gsub(//,'...').gsub(//,'&oelig;').gsub(/«/,'"').gsub(/»/,'"')
      review = @product.reviews.build(params[:review])
      review.customer = current_customer
      review.languages_id = DVDPost.product_languages[I18n.locale]
      review.save
      unless current_customer.has_rated?(@product)
        @product.ratings.create(:customer => current_customer, :value => params[:review][:rating])
        current_customer.seen_products << @product
        
        Customer.send_evidence('ItemRated', params[:product_id], current_customer, request, {:response_id => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser), :rule => params[:source]}, {:rating => params[:review][:rating]})
      end
      Customer.send_evidence('UserReview', params[:product_id], current_customer, request, {:response_id => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser), :rule => params[:source]})
      
      flash[:notice] = t('products.show.review.review_save')
    rescue Exception => e  
      flash[:error] = t('products.show.review.review_not_save')
    end
    
    respond_to do |format|
      format.html { redirect_to product_path(:id => @product.to_param, :source => params[:source]) }
      format.js {render :layout => false}
    end
  end
end
