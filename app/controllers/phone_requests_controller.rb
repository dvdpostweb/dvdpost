class PhoneRequestsController < ApplicationController
  def new
    @phone_request = PhoneRequest.new
    alert_start = Date.parse(General.find_by_CodeType('OFFLINE_CUST_START').value)
    alert_end = Date.parse(General.find_by_CodeType('OFFLINE_CUST_END').value)
    @alert = alert_start <= Date.today && alert_end >=Date.today ? true : false
  end

  def create
    @phone_request = PhoneRequest.new(params[:phone_request].merge(:customer_id => current_customer ? current_customer.to_param : 0 )) 
    if @phone_request.save
      flash[:notice] = t('messages.index.messages.phone_request_send_successfully')
      redirect_to ENV['HOST_OK'] == "0" ? messages_path : root_path
    else
      #flash[:error] = t('messages.index.messages.phone_request_not_send_successfully')
      render :action => :new
    end
  end
end