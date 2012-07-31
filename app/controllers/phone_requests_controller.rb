class PhoneRequestsController < ApplicationController
  def new
    @phone_request = ENV['HOST_OK'] == "0" ? PhoneRequest.new : PhoneRequestPublic.new
  end

  def create
    @phone_request = ENV['HOST_OK'] == "0" ? PhoneRequest.new(params[:phone_request].merge(:customer_id => current_customer.to_param)) : PhoneRequestPublic.new(params[:phone_request])
    if @phone_request.save
      flash[:notice] = t('messages.index.messages.phone_request_send_successfully')
      redirect_to ENV['HOST_OK'] == "0" ? messages_path : root_path
    else
      #flash[:error] = t('messages.index.messages.phone_request_not_send_successfully')
      render :action => :new
    end
  end
end