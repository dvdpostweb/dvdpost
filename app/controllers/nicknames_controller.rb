class NicknamesController < ApplicationController
  def update
    if !current_customer.customer_attribute.nickname_pending
      
      if current_customer.customer_attribute.update_attribute(:nickname_pending , params[:customer][:nickname])
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

  def edit
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end