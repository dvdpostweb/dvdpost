class NicknamesController < ApplicationController
  def create
    if current_customer.nicknames.waiting.count == 0
      @nickname = Nickname.new(params[:nickname].merge(:customer_id => current_customer.to_param))
      if @nickname.save
        flash[:notice] = t(:nickname_create)
        respond_to do |format|
          format.html do
            redirect_to customer_path(:id => current_customer.to_param)
          end
          format.js {render :layout => false}
        end
      else
        respond_to do |format|
          format.html {render :action => :new }
          format.js {render :action => :new, :layout => false}
        end
      end
    else
      @error = true
      respond_to do |format|
        format.html do
          redirect_to customer_path(:id => current_customer.to_param)
        end
        format.js {render :text => "tu peux pas faire cela"}
      end
    end
  end

  def new
    @nickname = Nickname.new
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end