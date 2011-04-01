class PromotionsController < ApplicationController
  def edit
    if current_customer.credit_per_month > 2 && Rails.env == "production"
      redirect_to customer_path(:id => current_customer.to_param)
    end
  end
  def show
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end
end
