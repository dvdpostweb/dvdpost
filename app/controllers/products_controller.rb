class ProductsController < ApplicationController
  def index
    @products = Product.available.by_kind(:normal)
    @products = @products.by_category(params[:category_id]) if params[:category_id] && !params[:category_id].empty?
    @products = @products.search(params[:search]) if params[:search]
    @products = @products.by_media(params[:media].keys) if params[:media]
    # @products = @products.by_type(params[:type].split(',')) if params[:type]
    @products = @products.by_public(params[:public_min], params[:year_max]) if params[:public_min] && params[:public_max]
    @products = @products.by_period(params[:year_min], params[:year_max]) if params[:year_min] && params[:year_max]
    @products = @products.by_duration(params[:duration_min], params[:duration_max]) if params[:duration_min] && params[:duration_max]
    @products = @products.by_soundtracks(params[:soundtrack].keys) if params[:soundtrack]
    @products = @products.by_picture_formats(params[:picture_format]) if params[:picture_format] && !params[:picture_format].empty?
    # @products = @products.by_colors(params[:color].keys) if params[:color]
    # @products = @products.by_oscars(params[:oscars].keys) if params[:oscars]
    @products = @products.by_country(params[:country]) if params[:country] && !params[:country].empty?
    @products = @products.paginate(:page => params[:page])
    @soundtracks = Soundtrack.all
    @picture_formats = PictureFormat.by_language(I18n.locale)
    @countries = ProductCountry.visible
    @selected_soundtracks = Soundtrack.by_soundtracks(params[:soundtrack].keys) if params[:soundtrack]
    @selected_picture_format = PictureFormat.by_language(I18n.locale).find(params[:picture_format]) if params[:picture_format] && !params[:picture_format].empty?
    @selected_country = ProductCountry.find(params[:country]) if params[:country] && !params[:country].empty?
  end

  def show
    @product = Product.available.find(params[:id])
    @categories = @product.categories
    @product.views_increment
    @reviews = @product.reviews.approved.paginate(:page => params[:reviews_page])
    @already_seen = current_customer.assigned_products.include?(@product)
    @reviews_count = @product.reviews.approved.count
    @synopsis = open("http://www.cinopsis.be/dvdpost_test.cfm?imdb_id=#{@product.imdb_id.to_s}") do |data|
      Hpricot(Iconv.conv('UTF-8', data.charset, data.read)).search('//p')
    end
  end

  def uninterested
    begin
      @product = Product.available.find(params[:product_id])
      @product.uninterested_customers << current_customer
      respond_to do |format|
        format.html {redirect_to product_path(:id => @product.to_param)}
        format.js   {render :partial => 'products/show/seen_uninterested', :locals => {:product => @product}}
      end
    end
  end

  def seen
    begin
      @product = Product.available.find(params[:product_id])
      @product.seen_customers << current_customer
      respond_to do |format|
        format.html {redirect_to product_path(:id => @product.to_param)}
        format.js   {render :partial => 'products/show/seen_uninterested', :locals => {:product => @product}}
      end
    end
  end
  
  def awards
    @product = Product.available.find(params[:product_id])
    respond_to do |format|
      format.js {render :partial => 'products/show/awards', :locals => {:product => @product, :size => 'full'}}
    end
  end
end
