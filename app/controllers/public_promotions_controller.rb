class PublicPromotionsController < ApplicationController
  def edit
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    discount = Discount.by_name(params[:promotion]).available
    activation = Activation.by_name(params[:promotion]).available
    if !discount.empty?
      render :text => php_path("step1.php?test=1&activation_code=#{params[:promotion]}");
    elsif !activation.empty?
      render :text => php_path("step1.php?test2&activation_code=#{params[:promotion]}");
    else
      respond_to do |format|
        format.html
        format.js {render :text => t('.public_promotion.update.error')}
      end
    end
  end
end