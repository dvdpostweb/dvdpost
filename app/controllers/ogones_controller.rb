class OgonesController < ApplicationController
  def show
    if current_customer.actived?
    else
      
      @ogone = OgoneCheck.find_by_orderid(params[:order_id])
      @product_abo = @ogone.product_abo
      current_customer.update_attributes(:ogone_owner => current_customer.name, :ogone_exp_date => params[:ed], :ogone_card_no => params[:cardno], :ogone_card_type => params[:brand])
      case @ogone.context
        when 'new_discount'
          if @ogone.discount_code_id > 0
            @discount = Discount.find(@ogone.discount_code_id)
            action = Subscription.action[:creation_with_discount]
            DiscountUse.create(:discount_code_id => @ogone.discount_code_id, :customer_id => current_customer.to_param, :discount_use_date => Time.now.localtime)
            @discount.update_attributes(:discount_limit => @discount.discount_limit - 1)
            duration = @discount.duration
            auto_stop = @discount.auto_stop
            recurring = @discount.recurring > 0 ? @discount.recurring.months.from_now + 1.day : 0
            credits = @discount.credits
            abo_dvd_remain = @discount.abo_dvd_remain && @discount.abo_dvd_remain > 0 ? @discount.abo_dvd_remain : 0
          else
            action = Subscription.action[:creation_without_promo]
            duration = 1.month.from_now.localtime
            auto_stop = 0
            recurring = 0
            credits = @product_abo.credits
            abo_dvd_remain = @product_abo.qty_dvd_max && @product_abo.qty_dvd_max > 0 ? @product_abo.qty_dvd_max : 0
          end
          current_customer.update_attributes(:customers_abo => 1, :customers_registration_step => 100,:customers_abo_payment_method => 1, :customers_abo_rank => 10, :customers_abo_start_rentthismonth => 0, :subscription_expiration_date => duration, :auto_stop => auto_stop, :customers_abo_discount_recurring_to_date => recurring)
          @ogone.product(:products_quantity => @ogone.product.products_quantity - 1)
          price = current_customer.promo_price
          credit_at_home = @product_abo.qty_at_home
          credit_at_home_adult = 0
          credit_history_action = price > 0 ? 5 : 4
          customer_credits = abo_dvd_remain > 0 ? credits : current_customer.credits + credits
          current_customer.manage_credits(current_customer.subscription_type, 15)
          current_customer.update_attributes(:customers_abo_dvd_norm => credit_at_home, :customers_abo_dvd_adult => credit_at_home_adult)
          if price > 0
            abo_action = 7
            current_customer.payment.create(:payment_method => 1, :abo_id => current_customer.abo_type_id, :amount => price, :payment_status => 2, :created_at => Time.now.localtime, :last_modified => Time.now.localtime)
          else
            abo_action = 17
          end
          current_customer.abo_history(action, current_customer.next_abo_type_id)
          current_customer.abo_history(abo_action, current_customer.next_abo_type_id)
          
        	if current_customer.gender == 'm' 
            gender = t('mails.gender_male')
          else
            gender = t('mails.gender_female')
          end
          promotion = ''
          options = {
            "\\$\\$\\$customers_name\\$\\$\\$" => "#{current_customer.first_name.capitalize} #{current_customer.last_name.capitalize}", 
            "\\$\\$\\$email\\$\\$\\$" => "#{current_customer.email}",
            "\\$\\$\\$gender_simple\\$\\$\\$" => gender ,
            "\\$\\$\\$mail_messages_sent_history_id\\$\\$\\$" => mail_history.to_param
            "\\$\\$\\$promotion\\$\\$\\$" => promotion
            "\\$\\$\\$final_price\\$\\$\\$" => price
            }
          send_mail(DVDPost.email[:welcome], current_customer, options)
          if current_customer.site == 'lavenir'
            send_mail(DVDPost.email[:lavenir], current_customer, options)
          end
      #to do activation_code_actions.php
        when 'new_activation'
      #to do activation by activation code
      end
      sponsor = Sponsorship.find_by_son_id(current_customer.to_param)
      unless sponsor
        sponsor_email = SponsorshipEmail.find_by_email(current_customer.email)
        if sponsor_email
          father = Customer.find(sponsor_email.customers_id)
          if father.actived?
            Sponsorship.create(:created_at => Time.now.localtime, :father_id => father.to_param, :son_id => current_customer.to_param , :points => 0)
            #to do send mail 447
          end
        end
      end  
    end
  end
  
end