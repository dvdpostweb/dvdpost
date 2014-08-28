class RatingsController < ApplicationController
  def create
    @product = Product.both_available.find(params[:product_id])
    @product.ratings.create(:customer => current_customer, :value => params[:value])
    current_customer.seen_products << @product
    respond_to do |format|
      format.html {redirect_to product_path(:id => @product.to_param, :source => params[:source])}
      format.js   {
        case params[:replace]
        when 'homepage'
          
          not_rated_products = current_customer.not_rated_products(params[:kind])
          not_rated_product = not_rated_products[rand(not_rated_products.count)]
          if not_rated_product 
            render :partial => 'home/index/wishlist_rating', :locals => {:product => not_rated_product}
          else
              render :nothing => true
          end
        when 'wishlist_start_list'
          filter = get_current_filter
          popular_page = session[:popular_page] || 1
          popular = current_customer.popular(filter, {:country_id => session[:country_id]}).paginate(:page => popular_page, :per_page => 8)
          if popular_page.to_i > 1 && popular.size == 0
            session[:popular_page] = popular_page.to_i - 1
            popular = current_customer.popular(filter, {:country_id => session[:country_id]}).paginate(:page => session[:popular_page], :per_page => 8)
          end
          render :partial => 'wishlist_items/popular', :locals => {:products => popular, :id => :popular_tab}
        else
          render :partial => 'products/rating', :locals => {:product => @product, :background => params[:background], :size => params[:size]}
        end
      }
    end
  end
end
