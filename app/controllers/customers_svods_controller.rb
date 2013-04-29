class CustomersSvodsController < ApplicationController
  def show
    
  end

  def update
    case current_customer.svod_adult
      when 0
        current_customer.abo_history(Subscription.action[:svod_adult_on], 130129)
        svod = CustomersSvod.find_or_create_by_customer_id(:customer_id => current_customer.id, :validity_period => 'month', :amount => 19.95, :product_abo_id => 130129)
        svod.update_attribute(:validityto, 2.hours.from_now.localtime.to_s(:db))
        current_customer.update_attribute(:svod_adult, 1)
      when 1
        current_customer.abo_history(Subscription.action[:svod_adult_off], 130129)
        current_customer.update_attribute(:svod_adult, 3)
      when 2
        current_customer.abo_history(Subscription.action[:svod_adult_off], 130129)
        current_customer.update_attribute(:svod_adult, 4)
      when 3
        current_customer.abo_history(Subscription.action[:svod_adult_break_off], 130129)
        current_customer.update_attribute(:svod_adult, 1)
      when 4
        current_customer.abo_history(Subscription.action[:svod_adult_break_off], 130129)
        current_customer.update_attribute(:svod_adult, 2)
    end
    flash[:notice] = 'done'
    redirect_to root_path()
  end
end