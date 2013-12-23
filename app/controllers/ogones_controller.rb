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
            recurring = @discount.recurring > 0 ? @discount.recurring.months.from_now + 1.day : nil
            credits = @discount.credits > 0 ? @discount.credits : @product_abo.credits
            abo_dvd_remain = 
            if @discount.abo_dvd_remain && @discount.abo_dvd_remain > 0
              @discount.abo_dvd_remain = 0
            elsif @product_abo.qty_dvd_max && @product_abo.qty_dvd_max > 0
              @product_abo.qty_dvd_max
            else
              0
            end
          else
            action = Subscription.action[:creation_without_promo]
            duration = 1.month.from_now.localtime
            auto_stop = 0
            recurring = nil
            credits = @product_abo.credits
            abo_dvd_remain = @product_abo.qty_dvd_max && @product_abo.qty_dvd_max > 0 ? @product_abo.qty_dvd_max : 0
          end
          
          price = current_customer.promo_price({:type => 'D', :discount_id => @ogone.discount_code_id})
          credit_history_action = price > 0 ? 5 : 4
          if price > 0
            abo_action = 7
            current_customer.payment.create(:payment_method => 1, :abo_id => current_customer.abo_type_id, :amount => price, :payment_status => 2, :created_at => Time.now.localtime, :last_modified => Time.now.localtime)
          else
            abo_action = 17
          end
        when 'new_activation'
          activation = Activation.find(@ogone.activation_code_id)
          action = Subscription.action[:creation_with_activation]
          price = 0
          duration = activation.duration
          auto_stop = activation.auto_stop
          recurring = 0
        	abo_action = 17
        	credit_history_action = 4
        	credits = activation.credits > 0 ? activation.credits : @product_abo.credits
          abo_dvd_remain = 
          if activation.abo_dvd_remain && activation.abo_dvd_remain > 0
            activation.abo_dvd_remain = 0
          elsif @product_abo.qty_dvd_max && @product_abo.qty_dvd_max > 0
            @product_abo.qty_dvd_max
          else
            0
          end
          activation.update_attributes(:created_at => Time.now.localtime.to_s(:db), :customers_id => current_customer.to_param)
          action = ActivationAction.find_by_activation_id(@ogone.activation_code_id)
          if action
            class_name = action.activation_class
            eval("action.action_#{class_name}(#{current_customer})")
          end
      end
      credit_at_home = @product_abo.qty_at_home
      credit_at_home_adult = 0
      current_customer.update_attributes(:customers_abo => 1, :customers_registration_step => 100,:customers_abo_payment_method => 1, :customers_abo_rank => 10, :customers_abo_start_rentthismonth => 0, :subscription_expiration_date => duration, :auto_stop => auto_stop, :customers_abo_discount_recurring_to_date => recurring, :customers_abo_dvd_norm => credit_at_home, :customers_abo_dvd_adult => credit_at_home_adult)
      current_customer.insert_credits(credits, abo_dvd_remain, credit_history_action)
      current_customer.abo_history(action, current_customer.next_abo_type_id)
      current_customer.abo_history(abo_action, current_customer.next_abo_type_id)
      @ogone.product(:products_quantity => @ogone.product.products_quantity - 1)
      if current_customer.gender == 'm' 
        gender = t('mails.gender_male')
      else
        gender = t('mails.gender_female')
      end
      
      options = {
        "\\$\\$\\$customers_name\\$\\$\\$" => "#{current_customer.first_name.capitalize} #{current_customer.last_name.capitalize}", 
        "\\$\\$\\$email\\$\\$\\$" => "#{current_customer.email}",
        "\\$\\$\\$gender_simple\\$\\$\\$" => gender,
        "\\$\\$\\$promotion\\$\\$\\$" => promotion(current_customer)[:promo],
        "\\$\\$\\$final_price\\$\\$\\$" => price,
        "\\$\\$\\$abo_price\\$\\$\\$" => price,
        "\\$\\$\\general_conditions\\$\\$\\$" => t('info.conditions.info'),
        "\\$\\$\\subscription\\$\\$\\$" => customer.subscription_type.description;
        }
      send_message(DVDPost.email[:welcome], options)
      if current_customer.site == 'lavenir'
        send_message(DVDPost.email[:lavenir], options)
      end
      
      
      sponsor = Sponsorship.find_by_son_id(current_customer.to_param)
      unless sponsor
        sponsor_email = SponsorshipEmail.find_by_email(current_customer.email)
        if sponsor_email
          father = Customer.find(sponsor_email.customers_id)
          if father.actived?
            Sponsorship.create(:created_at => Time.now.localtime, :father_id => father.to_param, :son_id => current_customer.to_param , :points => 0)
            options = {
              "\\$\\$\\$godfather_name\\$\\$\\$" => "#{father.first_name.capitalize} #{father.last_name.capitalize}", 
              "\\$\\$\\$son_name\\$\\$\\$" => "#{current_customer.first_name.capitalize} #{current_customer.last_name.capitalize}",
              "\\$\\$\\$godfather_point\\$\\$\\$" => father.inviation_points
              }
              send_message(DVDPost.email[:sponsorships_son], options, father)
          end
        end
      end  
    end
  end
end