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
          format.html {
            params[:ref] == 'product' ? redirect_to(shop_path) : redirect_back_or(shop_path)
          }
          format.js {
            init_data
            render :layout => false
          }
        end
      else
        flash[:error] = t 'shopping_carts.error'
        respond_to do |format|
          format.html {
            params[:ref] == 'product' ? redirect_to(shop_path) : redirect_back_or(shop_path)
          }
          format.js {
            init_data
            render :layout => false
          }
        end
      end
    else
      respond_to do |format|
        format.html {
          params[:ref] == 'product' ? redirect_to(shop_path) : redirect_back_or(shop_path)
        }
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
    flash[:notice] = t 'shopping_carts.drop'
    respond_to do |format|
      format.html {
        params[:ref] == 'product' ? redirect_to(shop_path) : redirect_back_or(shop_path)
      }
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
    redirect_to :action => "index"
  end

  def index
      @test = quantity_verify
      if @test
        if current_customer.shopping_carts.count == 0
          @test = false
        end
      end
      if params[:confirm] && @test

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
        @alias = current_customer.to_param
        @com= t '.shopping_carts.paiement'
        internal_com = 'dvdsale'
        @url_ok = php_path 'catalog.php'
        @url_back = url_for(:controller => 'payment_methods', :action => :edit, :customer_id => current_customer.to_param, :type => 'credit_card_modification', :only_path => false, :protocol => 'http')
        OgoneCheck.create(:orderid => @order_id, :amount => @price, :customers_id => current_customer.to_param, :context => internal_com, :site => 1)
        list = {:ACCEPTURL => @url_back, :ALIAS => @alias, :AMOUNT => @price, :CURRENCY => 'EUR', :LANGUAGE => @ogone_language, :ORDERID => @order_id, :PSPID => DVDPost.ogone_pspid[Rails.env], :CN => current_customer.name, :ALIASUSAGE => @com, :DECLINEURL => @url_back, :EXCEPTIONURL => @url_back, :CANCELURL => @url_back, :CATALOGURL => @url_ok, :COM => @com, :TP => php_path(@template_ogone)}
        list = list.merge(:PM => 'CreditCard', :BRAND => @brand) if !@brand.nil?
        list = list.sort_by {|k,v| k.to_s}
        string = list.map { |k,v| "#{k.to_s.upcase}=#{v}#{DVDPost.ogone_pass[Rails.env]}" }.join()
        @hash = Digest::SHA1.hexdigest(string)
        #@hash = Digest::SHA1.hexdigest("#{@order_id}#{@price}EURdvdpost#{current_customer.to_param}#{@com}KILLBILL")
      else
        @items = current_customer.shopping_carts.all
        @count = current_customer.shopping_carts.sum(:quantity)
        @articles_count = current_customer.shopping_carts.count
        price_data = ShoppingCart.price(current_customer)
        @total = price_data[:total]
        @hs = price_data[:hs]
        @shipping = price_data[:shipping]
        @reduce = price_data[:reduce]
        @price_reduced = price_data[:price_reduced]
      end
    end

    private
    def quantity_verify
      current_customer.shopping_carts.each do |c|
        if c.product.qty_sale == 0
          c.destroy
          flash[:error] = t 'shopping_carts.force_destroy', :title => c.product.title
          flash.discard(:error)
          return false
        elsif c.quantity > c.product.qty_sale
          c.update_attribute(:quantity, c.product.qty_sale)
          flash[:error] = t 'shopping_carts.force_update', :title => c.product.title, :quantity => c.product.qty_sale
          flash.discard(:error)
          return false
        end
      end
      return true
    end
    def redirect_back_or(path)
      redirect_to :back
    rescue ::ActionController::RedirectBackError
      redirect_to path
    end
    
    def init_data
      cart = current_customer.shopping_carts.ordered
      @cart = cart.paginate(:per_page => 3, :page => 1)

      @cart_count = current_customer.shopping_carts.sum(:quantity)
      price_data = ShoppingCart.price(current_customer)
      @price = price_data[:total]
      @shipping = price_data[:shipping]
      @reduce = price_data[:reduce]
      @price_reduced = price_data[:price_reduced]
    end
  end
