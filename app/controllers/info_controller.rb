class InfoController < ApplicationController
   
  def index
    if params[:page_name] == 'get_connected' || params[:page_name] == 'get_connected_order'
      unless current_customer
        @hide_menu = true
      end
    end
    if params[:page_name] == 'get_connected_order'
      params[:page_name] = 'get_connected'
      params[:order] = 1 
    end
    params[:page_name] = 'price_dvd' if params[:page_name] == 'price' && nederlands?
    if params[:page_name] == 'get_connected' || params[:page_name] == 'new_website'
      @locale = true
    else
      @locale = false
    end
    if params[:page_name] == 'free_movies'
      @product1 = Product.find(126024)
      @product2 = Product.find(126765)
      @product3 = Product.find(126690)
      @product4 = Product.find(110312)
    end
    params[:page_name] = "price" if params[:page_name] == 'pricel'
    if params[:page_name] == 'price' || params[:page_name] == 'price_dvd'
      @showing_abo = 25
      @list_abo = ProductAbo.find([127761,127762,127764,127766,127768,127769])
      @n = params[:page_name] == 'price' ? 6 : 7
      if !session[:code].nil?
        @promo_code = session[:code]
      else
        if nederlands?
          @promo_code = 'DVDNL'
        else
          case I18n.locale 
            when :fr
              @promo_code = 'univers'
            when :nl
              @promo_code = 'univers'
            when :en
              @promo_code = 'univers'
          end
        end
      end
    end

    if params[:page_name] == 'free_movies' || params[:page_name] == 'promotion'
      @theme = ThemesEvent.find(20)
    end
    @message = Ticket.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end
