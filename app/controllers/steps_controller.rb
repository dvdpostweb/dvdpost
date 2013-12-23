class StepsController < ApplicationController
  def show
    if params[:id].to_i == 1
      @abo_available = current_customer.get_list_abo(6)
      @showing_abo = 10
    elsif params[:id].to_i == 2
      @customer = current_customer
      @address = current_customer.build_address
      @address.customers_id = current_customer.to_param
      @countries = Country.all
    elsif params[:id].to_i == 3
    elsif params[:id].to_i == 4
      @promo = promotion(current_customer, true)
      classic_price = current_customer.price_per_month
      @promo_price = current_customer.promo_price
      if @promo_price == 0
        if current_customer.activation_discount_code_type == 'a' && current_customer.activation.activation_waranty == 2
          @type = :pre_paid
        else
          @type = :free
        end
      elsif @promo_price == classic_price
        @type = :payed
      else
        @type = :promo
      end
      if current_customer.payment_method == 1
        type="ogone"
      else
        type="callback"
      end
      @url = "http://www.dvdpost.be/belgie/conversion.php?campaignID=2946&productID=4211&conversionType=lead&https=0&transactionID=#{current_customer.to_param}&email=#{current_customer.email}&descrMerchant=#{type}&descrAffiliate=#{type}";
    elsif params[:id].to_i == 5
      @abo_available = current_customer.get_list_abo(6)
      @showing_abo = 10
    end
  end

  def update
    if params[:payment_type]
      if params[:payment_type] == 'VISA' || params[:payment_type] == 'American Express' || params[:payment_type] == 'Mastercard' 
        @order_id = "#{current_customer.to_param}#{Time.now.strftime('%Y%m%d%H%M%S')}"
        @price = (current_customer.promo_price * 100).to_i
        case I18n.locale
        	when :fr
        		@ogone_language = 'fr_FR'
        		@template_ogone = 'Template_standard2FR.htm'
        	when :nl
        		@ogone_language = 'nl_NL'
        		@template_ogone = 'Template_standard2NL.htm'
        	when :en
        		@ogone_language = 'en_US'
        		@template_ogone = 'Template_standard2EN.htm'
        end
        @com= t '.payment_methods.create'
      
        @url_back = url_for(:controller => 'steps', :action => :show, :id => 3, :only_path => false, :protocol => 'http')
        @brand = params[:payment_type]
        if current_customer.activation_discount_code_type == 'a'
          discount_code = 0
          activation_code = current_customer.activation_discount_code_id
          internal_com = 'new_activation'
        else
          discount_code = current_customer.activation_discount_code_id
          activation_code = 0
          internal_com = 'new_discount'
        end
        OgoneCheck.create(:orderid => @order_id, :amount => @price, :customers_id => current_customer.to_param, :context => internal_com, :site => 1, :products_id => current_customer.abo_type_id, :discount_code_id => discount_code, :activation_code_id => activation_code)
        @hash = Digest::SHA1.hexdigest("#{@order_id}#{@price}EURdvdpost#{current_customer.to_param}#{@com}KILLBILL")
      elsif params[:payment_type] == 'bank'
        current_customer.update_attribute(:customers_registration_step, 100)
        if current_customer.gender == 'm' 
          gender = t('mails.gender_male')
        else
          gender = t('mails.gender_female')
        end
        price = current_customer.promo_price
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
        redirect_to step_path(:id => 4)
      else
        flash[:error] = "make your choice"
        flash.discard(:error)
        render :show
      end
    else #step 1
      if(params[:customer] != nil && params[:customer][:next_abo_type_id] && !params[:customer][:next_abo_type_id].empty?)
        if current_customer.customers_registration_step.to_i == 90
          current_customer.update_attributes(:abo_type_id => params[:customer][:next_abo_type_id].to_i, :next_abo_type_id => params[:customer][:next_abo_type_id].to_i, :customers_registration_step => 31, :customers_abo_suspended => 0, :nb_recurring => nil, :free_upgrade => 0)
        else
          current_customer.update_attributes(:abo_type_id => params[:customer][:next_abo_type_id].to_i, :next_abo_type_id => params[:customer][:next_abo_type_id].to_i, :customers_registration_step => 31)
        end
        redirect_to step_path(:id => 2)
      else
        flash[:error] = "make your choice"
        flash.discard(:error)
        render step_path(:id => 1)
      end
    end
  end
end