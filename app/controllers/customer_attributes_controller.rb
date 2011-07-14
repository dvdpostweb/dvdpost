class CustomerAttributesController < ApplicationController
  def update
    @attribute = current_customer.customer_attribute
    if !@attribute.nickname_pending
      
      if @attribute.update_attributes(params[:customer_attribute])
        flash[:notice] = t(:nickname_create)
        respond_to do |format|
          format.html do
            redirect_to customer_path(:id => current_customer.to_param)
          end
          format.js {render :layout => false}
        end
      else
        respond_to do |format|
          format.html {render :action => :edit }
          format.js {render :action => :edit, :layout => false}
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
    @attribute = current_customer.customer_attribute
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end