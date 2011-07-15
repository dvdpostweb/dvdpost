class AvatarsController < ActionController::Base
  def avatar
    send_data CustomerAttribute.find_by_customer_id(params[:customer_id]).avatar, :type => 'image/jpg', :disposition => 'inline'
  end

  def avatar_pending
    send_data CustomerAttribute.find_by_customer_id(params[:customer_id]).avatar_pending, :type => 'image/jpg', :disposition => 'inline'
  end
end