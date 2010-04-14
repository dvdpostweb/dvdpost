class ProductsController < ApplicationController
  def index
    @products = Product.by_kind(:normal)
    @products = @products.search(params[:search]) if params[:search]
    @products = @products.by_media(params[:media].split(',')) if params[:media]
    @products = @products.paginate(:page => params[:page])
  end

  def show
    @product = Product.find(params[:id])
    @product.views_increment
    @reviews = @product.reviews.paginate(:page => params[:reviews_page])
    @reviews_count = @product.reviews.count
  end

  def uninterested
    begin
      @product = Product.find(params[:product_id])
      @product.uninterested_customers << current_customer
      respond_to do |format|
        format.html {redirect_to product_path(:id => @product.to_param)}
        format.js   {render :partial => 'products/show/seen_uninterested', :locals => {:product => @product}}
      end
    end
  end
end
