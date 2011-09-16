class ReviewsController < ApplicationController

  def index
    if params[:sort]
      sort = Review.sort[params[:sort].to_sym]
    else
      sort = Review.sort[:date]
    end
    if params[:kind] == :adult
      @reviews = Review.by_customer_id(params[:customer_id]).approved.ordered(sort).find(:all,:joins => :product, :conditions => { :products => {:products_status => [-2,0,1]}}).paginate(:page => params[:page], :per_page => 10)
      @reviews_count = Review.by_customer_id(params[:customer_id]).approved.find(:all,:joins => :product, :conditions => { :products => {:products_status => [-2,0,1]}}).count
    else
      @reviews = Review.by_customer_id(params[:customer_id]).approved.ordered(sort).find(:all,:joins => :product, :conditions => { :products => {:products_type => DVDPost.product_kinds[params[:kind]], :products_status => [-2,0,1]}}).paginate(:page => params[:page], :per_page => 10)
      @reviews_count = Review.by_customer_id(params[:customer_id]).approved.find(:all,:joins => :product, :conditions => { :products => {:products_type => DVDPost.product_kinds[params[:kind]], :products_status => [-2,0,1]}}).count
    end
    
    @customer = Customer.find(params[:customer_id])
    @source = @wishlist_source[:reviews]
  end

  def show
    @review = Review.find(params[:id])
  end

  def new
    @product = Product.both_available.find(params[:product_id])
    @review = Review.new(:products_id => params[:product_id])
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    begin
      @product = Product.both_available.find(params[:product_id])
      review = @product.reviews.build(params[:review])
      review.customer = current_customer
      review.languages_id = DVDPost.product_languages[I18n.locale]
      review.save
      unless current_customer.has_rated?(@product)
        @product.ratings.create(:customer => current_customer, :value => params[:review][:rating])
        current_customer.seen_products << @product
        Customer.send_evidence('Rating', params[:product_id], current_customer, request.remote_ip, {:rating => params[:review][:rating]})
      end
      flash[:notice] = t('products.show.review.review_save')
    rescue Exception => e  
      flash[:notice] = t('products.show.review.review_not_save')
    end
    redirect_to product_path(:id => @product.to_param)
  end
end
