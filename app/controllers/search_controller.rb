class SearchController < ApplicationController
  def index
    @body_id = 'search_index'
    @jacket_mode = Product.get_jacket_mode(params)
    @rating_color = :white
    @tokens = current_customer.get_all_tokens_id(params[:kind]) if current_customer
    @filter = get_current_filter({})
    new_params = session[:sexuality] == 0 ? params.merge(:per_page => 15, :country_id => session[:country_id], :hetero => 1) : params.merge(:per_page => 15, :country_id => session[:country_id])
    @products = Product.filter(@filter, new_params)
    @directors = params[:kind] == :normal ?  Director.search_clean(params[:search], params[:page]) : 0
    @actors = Actor.search_clean(params[:search], params[:kind], params[:page])
    @countries = ProductCountry.visible.order
    @source = @wishlist_source[:search]
    if params[:endless]
      cookies.permanent[:endless] = params[:endless]
    end
    if params[:type].nil?
      if @products.count > 0
        @active = 'products'
      elsif @actors.count > 0
        @active = 'actors'
      elsif @directors != 0 && @directors.count > 0
        @active = 'directors'
      else
        @active = 'products'
      end
    else
      @active = params[:type]
    end
    if @active == 'products'
      @item = @products
    elsif @active == 'actors'
      @item = @actors
    elsif @active == 'directors'
      @item = @directors
    end
  end
end
