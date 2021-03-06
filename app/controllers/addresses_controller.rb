class AddressesController < ApplicationController
  def edit
    @address = current_customer.address
    unless @address
      @address = Address.new
    end
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def create
    @address = Address.new(params[:address].merge(:customer => current_customer))
    if @address.save
      current_customer.update_attribute(:address_id, @address.address_book_id)
      respond_to do |format|
        format.html do
          flash[:notice] = t(:address_modify)
          redirect_to customer_path(:id => current_customer.to_param)
        end
        format.js
      end
    else
      respond_to do |format|
        format.html do
          render :action => :edit
        end
        format.js do
          render :action => :edit, :layout => false
        end
      end
    end
  end
end
