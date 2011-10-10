class InfoController < ApplicationController
   
  def index
    if params[:page_name] == 'get_connected' || params[:page_name] == 'get_connected_order'
      unless current_customer
        @hide_menu = true
      end
    end
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
