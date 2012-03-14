class TrailersController < ApplicationController
  def show
    @trailer = Trailer.find(params[:id])
    respond_to do |format|
      format.html{render :layout => false}
      format.js {render :layout => false}
    end
  end
end