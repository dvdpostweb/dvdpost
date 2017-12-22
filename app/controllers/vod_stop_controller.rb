class VodStopController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

end
