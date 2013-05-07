class CustomersSvodsController < ApplicationController
  def show
    
  end

  def edit
    respond_to do |format|
      format.html
      format.js {render :layout => false}
    end
  end

  def update
    case current_customer.svod_adult
      when 0
        current_customer.abo_history(Subscription.action[:svod_adult_on], DVDPost.svod_adult_product[Rails.env])
        svod = CustomersSvod.find_or_create_by_customer_id(:customer_id => current_customer.id, :validity_period => 'month', :amount => DVDPost.svod_adult_price, :product_abo_id => DVDPost.svod_adult_product[Rails.env])
        svod.update_attribute(:validityto, 2.hours.from_now.localtime.to_s(:db))
        current_customer.update_attribute(:svod_adult, 1)
        name = 'activate'
      when 1
        current_customer.abo_history(Subscription.action[:svod_adult_off], DVDPost.svod_adult_product[Rails.env])
        current_customer.update_attribute(:svod_adult, 3)
        name = 'deactivate'
      when 2
        current_customer.abo_history(Subscription.action[:svod_adult_off], DVDPost.svod_adult_product[Rails.env])
        current_customer.update_attribute(:svod_adult, 4)
        name = 'deactivate'
      when 3
        current_customer.abo_history(Subscription.action[:svod_adult_break_off], DVDPost.svod_adult_product[Rails.env])
        current_customer.update_attribute(:svod_adult, 1)
        name = 'break'
      when 4
        current_customer.abo_history(Subscription.action[:svod_adult_break_off], DVDPost.svod_adult_product[Rails.env])
        current_customer.update_attribute(:svod_adult, 2)
        name = 'break'
    end
    flash[:notice] = t("customers_svods.update.status_#{name}", :next_reconduction_at => CustomersSvodHelper.next_reconduction_at(current_customer))
    redirect_to root_path()
  end
end
