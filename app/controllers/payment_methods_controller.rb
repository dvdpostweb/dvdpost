class PaymentMethodsController < ApplicationController
  def edit
  end

  def update
    @order_id = "#{current_customer.to_param}#{Time.now.strftime('%Y%m%d%H%M%S')}"
    @price = 0;
    case I18n.locale
    	when :fr
    		@ogone_language = 'fr_FR'
    		@template_ogone = 'Template_freetrial2FR.htm'
    	when :nl
    		@ogone_language = 'nl_NL';
    		@template_ogone = 'Template_freetrial2NL.htm'
    	when :en
    		@ogone_language = 'en_US';
    		@template_ogone = 'Template_freetrial2EN.htm'
    end
    @brand = params[:brand] if params[:brand]
    if params['type'] == 'credit_card_modification'
      @com= t '.payment_methods.update.payment_update'
      internal_com = 'ogone_change'
      @url_back = url_for(:controller => 'payment_methods', :action => :edit, :customer_id => current_customer.to_param, :type => 'credit_card_modification', :only_path => false, :protocol => 'http')
    elsif params['type'] == 'credit_card_for_ppv'
      @com= t '.payment_methods.update.payment_ppv'
      internal_com = 'ogone_for_ppv'
      @url_back = url_for(:controller => 'payment_methods', :action => :edit, :customer_id => current_customer.to_param, :type => 'credit_card_for_ppv', :only_path => false, :protocol => 'http')
    else
      @com= t '.payment_methods.update.payment_change'
      @url_back = url_for(:controller => 'payment_methods', :action => :edit, :customer_id => current_customer.to_param, :type => 'credit_card', :only_path => false, :protocol => 'http')
      internal_com = 'payment_method_change'
    end
    OgoneCheck.create(:orderid => @order_id, :amount => @price, :customers_id => current_customer.to_param, :context => internal_com, :site => 1)
    @alias = current_customer.to_param
    @url_ok = php_path 'catalog.php'
    list = {:ACCEPTURL => @url_back, :ALIAS => @alias, :AMOUNT => @price, :CURRENCY => 'EUR', :LANGUAGE => @ogone_language, :ORDERID => @order_id, :PSPID => DVDPost.ogone_pspid[Rails.env], :CN => current_customer.name, :ALIASUSAGE => @com, :DECLINEURL => @url_back, :EXCEPTIONURL => @url_back, :CANCELURL => @url_back, :CATALOGURL => @url_ok, :COM => @com, :TP => php_path(@template_ogone)}
    list = list.merge(:PM => 'CreditCard', :BRAND => @brand) if !@brand.nil?
    list = list.sort_by {|k,v| k.to_s}
    string = list.map { |k,v| "#{k.to_s.upcase}=#{v}#{DVDPost.ogone_pass[Rails.env]}" }.join()
    #if Rails.env == 'production'
    #  @hash = Digest::SHA1.hexdigest("#{@order_id}#{@price}EUR#{DVDPost.ogone_pspid[Rails.env]}#{current_customer.to_param}#{@com}#{DVDPost.ogone_pass[Rails.env]}")
    #else
      @hash = Digest::SHA1.hexdigest(string)
    #end
  end
end
