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
    @message = Ticket.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end
