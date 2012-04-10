class OgonesController < ApplicationController
  def show
    if current_customer.abo?
    else
      @ogone = OgoneCheck.find_by_orderid(params[:order_id])
      @product_abo = @ogone.product_abo
      current_customer.update_attributes(:ogone_owner => current_customer.name, :ogone_exp_date => params[:ed], :ogone_card_no => params[:cardno], :ogone_card_type => params[:brand])
      case @ogone.context
        when 'new_discount'
          if @ogone.discount_code_id > 0
            @discount = discount.find(@ogone.discount_code_id)
            action = Subscription.action[:creation_with_discount]
            DiscountUse.create(:discount_code_id => @ogone.discount_code_id, :customer_id => current_customer.to_param)
            @discount.update_attribute(:discount_limit => @discount.discount_limit - 1)
            duration = @discount.duration
            auto_stop = @discount.auto_stop
            recurring = @discount.recurring > 0 ? @discount.recurring.months.from_now + 1.day : 0
          else
            action = Subscription.action[:creation_without_promo]
            duration = 1.month.from_now.localtime
            auto_stop = 0
            recurring = 0
          end
          current_customer.update_attributes(:customers_abo => 1, :customers_registration_step => 100,:customers_abo_payment_method => 1, :customers_abo_rank => 10, :customers_abo_start_rentthismonth => 0, :subscription_expiration_date => duration, :auto_stop => auto_stop, :customers_abo_discount_recurring_to_date => recurring)
          Subscription.create(:customers_id => current_customer.to_param, :code_id => @ogone.discount_code_id, :action => , :date => Time.now.localtime, :product_id => @ogone.product_id, :payment_method => 'OGONE', :site => 1)
          @ogone.product(:products_quantity => @ogone.product - 1)
        when 'new_activation'  
          
      end
      #to do activation_code_actions.php
      #to do parrainage
    end
  end
end