class ProductsController < ApplicationController
  before_filter :find_product, :only => [:uninterested, :seen, :awards, :trailer]

  def index
    params.delete(:id)
    params.delete(:controller)
    params.delete(:action)
    redirect_to movies_path(params)
  end

  def show
    movie = Product.find_by_old_product_id(params[:id]).movie
    params.delete(:id)
    params.delete(:controller)
    params.delete(:action)
    params[:id] = movie.to_param
    
    redirect_to movie_path(params)
  end

  def uninterested
    unless current_customer.rated_products.include?(@product) || current_customer.seen_products.include?(@product) || current_customer.uninterested_products.include?(@product)
      @product.uninterested_customers << current_customer
      Customer.send_evidence('NotInterestedItem', @product.to_param, current_customer, request.remote_ip)
    end
    respond_to do |format|
      format.html {redirect_to product_path(:id => @product.to_param)}
      format.js   {render :partial => 'products/show/seen_uninterested', :locals => {:product => @product}}
    end
  end

  def seen
    @product.seen_customers << current_customer
    Customer.send_evidence('AlreadySeen', @product.to_param, current_customer, request.remote_ip)
    respond_to do |format|
      format.html {redirect_to product_path(:id => @product.to_param)}
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
      format.js   {render :partial => 'products/trailer', :locals => {:trailer => trailer.first, :trailers => trailer}}
      format.html do
        if trailer.first && trailer.first.url
          redirect_to trailer.first.url
        else
          redirect_to product_path(:id => @product.to_param)
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
    expire_fragment ("/fr/products/product_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_#{params[:product_id]}")
    expire_fragment ("/en/products/product_#{params[:product_id]}")
    render :nothing => true
  end
private
  def find_product
    if params[:kind] == :normal
      @product = Product.normal_available.find(params[:product_id])
    else
      @product = Product.adult_available.find(params[:product_id])
    end
  end
end
