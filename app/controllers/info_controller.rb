class InfoController < ApplicationController
   
  def index
    if params[:page_name] == 'get_connected' || params[:page_name] == 'get_connected_order'
      unless current_customer
        @hide_menu = true
      end
    end
    if params[:page_name] == 'whoweare' || params[:page_name] == 'privacy' || params[:page_name] == 'conditions' || params[:page_name] == 'presse' || params[:page_name] == 'promo' || params[:page_name] == 'billi' || params[:page_name] == 'billi_modal' || params[:page_name] == 'billi_modal2'
      @locale = false
    else
      @locale = true
    end
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end
