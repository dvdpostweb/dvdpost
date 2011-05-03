class StreamingReportsController < ApplicationController
  def new
    @product = Product.both_available.find_by_imdb_id(params[:streaming_product_id])
    @message = Ticket.new
    
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    
  end
end
