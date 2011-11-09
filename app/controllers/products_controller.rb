class ProductsController < ApplicationController
  before_filter :find_product, :only => [:uninterested, :seen, :awards, :trailer, :show]

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

  def drop_cached
    expire_fragment ("/fr/products/product_1_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_1_#{params[:product_id]}")
    expire_fragment ("/en/products/product_1_#{params[:product_id]}")
    expire_fragment ("/fr/products/product_0_#{params[:product_id]}")
    expire_fragment ("/nl/products/product_0_#{params[:product_id]}")
    expire_fragment ("/en/products/product_0_#{params[:product_id]}")
    render :nothing => true
  end
private
  def find_product
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
  end
end
