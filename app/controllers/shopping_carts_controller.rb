class ShoppingCartsController < ApplicationController
  def create
    item = current_customer.shopping_carts.find_by_products_id(params[:shopping_cart][:products_id])
    unless item
      @product = Product.find(params[:shopping_cart][:products_id])
      @cart_new = ShoppingCart.new(params[:shopping_cart].merge(:customer => current_customer, :price => @product.price_sale))
      @submit_id = "id_#{@product.id}"
      if @cart_new.save
        flash[:notice] = t 'shopping_carts.success'
        respond_to do |format|
          format.html {redirect_back_or(shopping_cart_path)}
          format.js {
            init_data
            render :layout => false
          }
        end
      else
        flash[:error] = t 'shopping_carts.error'
        respond_to do |format|
          format.html {redirect_back_or(shopping_cart_path)}
          format.js {
            init_data
            render :layout => false
          }
        end
      end
    else
      respond_to do |format|
        format.html {redirect_back_or(shop_path)}
        format.js {
          init_data
          render :layout => false
        }
      end
    end
  end

  def destroy
    item = current_customer.shopping_carts.find(params[:id])
    @product = item.product
    @submit_id = "id_#{@product.id}"
    item.destroy if item 
    respond_to do |format|
      format.html {redirect_back_or(shop_path)}
      format.js {
        init_data
        render :layout => false
      }
    end
  end

  def update
    item = current_customer.shopping_carts.find(params[:id])
    
    if params[:shopping_cart][:quantity].to_i <= item.product.qty_sale
      item.update_attributes(params[:shopping_cart])
    end
    flash[:notice] = t 'shopping_carts.up'
    redirect_to :action => "index"
  end

  def index
    if params[:confirm]
      @order_id = "#{current_customer.to_param}#{Time.now.strftime('%Y%m%d%H%M%S')}"
      price_data = ShoppingCart.price(current_customer)
      @price = price_data[:total]
      @price *= 100
      @price = @price.round
      case I18n.locale
      	when :fr
      		@ogone_language = 'fr_FR'
      		@template_ogone = 'Template_freetrial2FR.htm'
      	when :nl
      		@ogone_language = 'nl_NL';
      		@template_ogone = 'Template_freetrial2NL.htm'
      	when :en
      		@ogone_language = 'en_US';
      		@template_ogone = 'Template_freetrial2EN.htm'
      end
      @com= t '.payment_methods.update.payment_update'
      internal_com = 'dvdsale'
      @url_back = url_for(:controller => 'payment_methods', :action => :edit, :customer_id => current_customer.to_param, :type => 'credit_card_modification', :only_path => false, :protocol => 'http')
      OgoneCheck.create(:orderid => @order_id, :amount => @price, :customers_id => current_customer.to_param, :context => internal_com, :site => 1)
      @hash = Digest::SHA1.hexdigest("#{@order_id}#{@price}EURdvdpost#{current_customer.to_param}#{@com}KILLBILL")
    else
      @items = current_customer.shopping_carts.all
      @count = current_customer.shopping_carts.sum(:quantity)
      @articles_count = current_customer.shopping_carts.count
      price_data = ShoppingCart.price(current_customer)
      @total = price_data[:total]
      @hs = price_data[:hs]
      @shipping = price_data[:shipping]
    end
  end

  private
  def redirect_back_or(path)
    redirect_to :back
  rescue ::ActionController::RedirectBackError
    redirect_to path
  end
  def init_data
    cart = current_customer.shopping_carts.ordered
    @cart = cart.paginate(:per_page => 3, :page => 1)
    
    @count = current_customer.shopping_carts.sum(:quantity)
    price_data = ShoppingCart.price(current_customer)
    @price = price_data[:ttc]
    @shipping = price_data[:shipping]
  end
end