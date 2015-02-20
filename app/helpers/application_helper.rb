# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  protected
  def switch_locale_link(locale, options=nil)
    if params['controller'] == "home" && params['action'] == "index"
      link_to locale.to_s.upcase, root_path(params.merge(:locale => locale)), options
    elsif params['controller'] == "products" && params['action'] == "index"
      link_to locale.to_s.upcase, products_path(params.merge(:locale => locale)), options
    else
      link_to locale.to_s.upcase, params.merge(:locale => locale), options
    end
  end

  def product_media_id(media)
    case media
      when 'DVD', 'HDD', 'PS3', 'Wii' then media.downcase
      when 'BlueRay'                  then 'bluray'
      when 'bluray3d'                  then 'bluray3d'
      when 'bluray3d2d'                  then 'bluray3d'
      when 'XBOX 360'                 then 'xbox'
      else ''
    end
  end


  def list_indicator_class(value)
    case value
      when 0..9 then 'low'
      when 10..29 then 'medium'
      else 'high'
    end
  end
  def color(status)
    case status
    when 'YES'
      'green'
    when 'NO'
      'red'
    else
      'orange'
  end
      
  end
  def redirect_after_registration(path = nil)
    #if current_customer
    #  if current_customer.customers_registration_step.to_i == 31
    #    if (params['controller'] == 'steps' && params[:id].to_i == 2) || (params[:controller] == 'customers' && params[:action] == 'update')
    #    else
    #      redirect_to step_path(:id => 2)
    #    end
    #  elsif current_customer.customers_registration_step.to_i == 21
    #    if (params['controller'] == 'steps' && params[:id].to_i == 1)
    #    else
    #      redirect_to step_path(:id => 1)
    #    end
    #  elsif current_customer.customers_registration_step.to_i == 33
    #    if (params['controller'] == 'steps' && params[:id].to_i == 3) || (params[:controller] == 'ogones' && params[:action] == 'show')
    #    else
    #      redirect_to step_path(:id => 3)
    #    end
    #  elsif current_customer.customers_registration_step.to_i == 90
    #    if (params['controller'] == 'steps' && params[:id].to_i == 5) || (params['controller'] == 'steps' && params[:id].to_i == 1 && params[:action] == 'update')
    #    else
    #      redirect_to step_path(:id => 5)
    #    end
    #  elsif params[:controller] == 'steps' && params[:id].to_i != 4 && (current_customer.customers_registration_step.to_i == 100 || current_customer.customers_registration_step.to_i == 95)
    #    redirect_to root_path
    #  elsif current_customer.customers_registration_step.to_i != 100  && current_customer.customers_registration_step.to_i != 95
    #    redirect_to php_path
    #  elsif path
    #    redirect_to path
    #  end
    #end
    if current_customer
      if current_customer.customers_registration_step.to_i == 80
        if params[:controller] != 'shops' && params[:controller] != 'shopping_carts' && params[:controller] != 'shopping_orders' && !(params[:controller] == 'info' && params[:page_name] == 'buy') && !(params[:controller] == 'info' && params[:page_name] == 'withdrawal_period') && params[:controller] != 'phone_requests' && params[:action] != 'validation'
          redirect_to shop_path(:locale => params[:locale], :kind => :normal) and return
        end
      elsif current_customer.customers_registration_step.to_i == 90
        redirect_to php_path("step_member_choice.php")
      elsif current_customer.customers_registration_step.to_i != 100  && current_customer.customers_registration_step.to_i != 95
        redirect_to php_path("step1.php")
      end
    end
  end

  def nederlands?
    request.host_with_port.include?('dvdpost.nl') || Rails.env == 'development' 
  end

  def localized_image_tag(source, options={})
    image_tag File.join(I18n.locale.to_s, source), options
  end

  def save_attempted_path
    session[:attempted_path] = request.request_uri
  end

  def wishlist_size
    @wishlist_size = (current_customer.wishlist_items.available.by_kind(:normal).current.include_products.count || 0) if current_customer
  end

  def delegate_locale
    if params[:kind].nil?
      params[:kind] = :normal
    end
  end

  def messages_size
    @messages_size = (current_customer.tickets.find(:all, :include => :message_tickets, :conditions =>  ["message_tickets.`is_read` = 0 and message_tickets.user_id > 0"]).count || 0) if current_customer
  end

  def current_customer
    current_user
  end

  def oauth_client
    params = OAUTH.clone
    client_id = params.delete(:client_id)
    client_secret = params.delete(:client_secret)
    @client ||= OAuth2::Client.new(
      client_id, client_secret, params
    )
  end

  def oauth_client2
    params = OAUTH.clone
    if nederlands?
      params[:site] = 'https://sso.dvdpost.nl'
      params[:client_id] = 'dvdpost_nl_rails_client'
      params[:client_secret] = 'dvdpost_nl_rails_client_secret'
    end
    client_id = params.delete(:client_id)
    client_secret = params.delete(:client_secret)
    @client ||= OAuth2::Client.new(
      client_id, client_secret, params
    )
  end

  def oauth_token
    session[:oauth_token] ? OAuth2::AccessToken.new(oauth_client, session[:oauth_token]) : nil
  end

  def redirect_url_after_sign_out
    prefix = mobile_request? ? "http://m." : "http://"
    case Rails.env
      when "production"
        if request.host_with_port.include?('dvdpost.nl')
          "#{prefix}private.dvdpost.nl/#{I18n.locale}"
        else
          "#{prefix}public.dvdpost.com/#{I18n.locale}"
        end
      when "pre_production"
        "#{prefix}beta.public.dvdpost.com/#{I18n.locale}"
      when "staging"
        "#{prefix}staging.public.dvdpost.com/#{I18n.locale}"
      when "development"
        if request.host_with_port.include?('dvdpost.nl')
          "#{prefix}private.dvdpost.nl/#{I18n.locale}"
        else
          "#{prefix}public.dvdpost.dev/#{I18n.locale}"
        end
    end
  end

  def twitter_url
    "http://twitter.com/dvdpost"
  end

  def vimeo_url
    "http://vimeo.com/5199678"
  end

  def javascript(*args)
    content_for(:head) { javascript_include_tag(*args) }
  end

  def stylesheet(*args)
    content_for(:head) { stylesheet_link_tag(*args) }
  end

  def parent_layout(layout)
    @content_for_layout = self.output_buffer
    self.output_buffer = render(:file => "layouts/#{layout}")
  end

  def php_path(path=nil)
    country_id = current_customer && current_customer.addresses.length > 0  ? current_customer.addresses.first.entry_country_id : nil
    host = case  Rails.env
      when 'development' 
        'http://localhost/'
      when 'staging'
        'http://test/'
      else
        production_path(country_id)
    end
    result = "#{host}#{path}"
    "#{result}#{result.include?('?') ? '&' : '?'}language=#{I18n.locale}"
  end

  def product_public_path(product)
    "http://public.dvdpost.com/#{I18n.locale}/products/#{product.to_param}"
  end

  def remote_carousel_path(carousel)
    php_path carousel
  end

  def production_path(country_id=nil)
    if current_customer
      if country_id.to_i == 150 || nederlands?
        'http://www.dvdpost.nl/'
      elsif country_id.to_i == 124
        'http://www.dvdpost.lu/'
      else
        'http://www.dvdpost.be/'
      end
    else
      if session[:country_code] == 'NL' || nederlands?
        'http://www.dvdpost.nl/'
      elsif session[:country_code] == 'LU' 
        'http://www.dvdpost.lu/'
      else
        'http://www.dvdpost.be/'
      end
    end
  end

  def product_assigned_path(product)
    if product
      if product.adult?
        product_path(:kind => :adult, :id => product.to_param, :source => @wishlist_source[:wishlist_dvd])
      else
        product_path(:kind => :normal, :id => product.to_param, :source => @wishlist_source[:wishlist_dvd])
      end
    end
  end

  def product_streaming_path(stream)
    product = stream.products.first
    if product
      if product.adult?
        streaming_product_path(:kind => :adult, :id => product.imdb_id)
      else
        streaming_product_path(:kind => :normal, :id => product.imdb_id)
      end
    end
  end

  def product_assigned_title(product)
    if product
      if product.adult? && params[:kind] == :normal
        t('wishlit_items.index.adult_title')
      else
        product.title
      end
    else
      ''
    end
  end

  def email_data_replace(text,options)
    options.each {|key, value| 
      r = Regexp.new(key, true)
      text = text.gsub(r, value.to_s)
    }
    text
  end

  def distance_of_time_in_hours(from_time,to_time)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_hours = (((to_time - from_time).abs)/3600)
    if(distance_in_hours<1)
      "#{(((to_time - from_time).abs)/60).round} #{t('time.minutes')}"
    else
      distance_in_hours = distance_in_hours.round
      "#{distance_in_hours} #{distance_in_hours == 1 ? t('time.hour') : t('time.hours')}"
    end
  end

  def time_left(stream, kind)
    if stream.products.first.kind == DVDPost.product_kinds[:adult]
      hours_left = DVDPost.hours[:adult]
    else
      hours_left = DVDPost.hours[:normal]
    end
    distance_of_time_in_hours((stream.updated_at + hours_left.hours), Time.now.localtime)
  end

  
  def streaming_access?
    !nederlands? && (!current_customer || session[:country_id] == 22 || session[:country_id] == 131 || session[:country_id] == 0 || current_customer.super_user? ) || session[:country_id] == 161
  end

  def set_title(alter_title, replace = true)
    if alter_title.blank?
      @title = t '.title'
    else
      if replace
        @title = alter_title
      else
        @title = "#{t '.title'} - #{alter_title}"
      end
    end
  end

  def streaming_btn_title(type, text)
    if(type == :replay)
      text == :short ? t('.replay_short') : t('.replay')
    else
      text == :short ? t('.buy_short') : t('.buy')
    end
  end

  def streaming_ppv_btn_title(type, text, price)
    text == :short ? t('.ppv_short', :price => price) : t('.ppv', :price => price)
  end

  def sort_collection_for_select
    options = []
    codes_hash = Product.list_sort
    codes_hash.each {|key, code| options.push [t(".#{key}"), key]}
    options
  end

  def sort_review_for_select
    options = []
    codes_hash = Review.sort
    codes_hash.each {|key, code| options.push [t(".#{key}"), key]}
    options
  end

  def sort_review2_for_select
    options = []
    codes_hash = Review.sort2
    codes_hash.each {|key, code| options.push [t(".#{key}"), key]}
    options
  end

  def get_current_filter(options = {})
    if cookies[:filter_id]
      current_filter = SearchFilter.get_filter(cookies[:filter_id])
      unless current_filter.to_param
        current_customer.customer_attribute.update_attributes(:filter_id => nil) if current_customer
        cookies.delete :filter_id
      end
      if !options.empty?
        current_filter.update_with_defaults(options)
      end
    else
      if current_customer && current_customer.customer_attribute.filter_id
        cookies[:filter_id] = { :value => current_customer.customer_attribute.filter_id, :expires => 1.year.from_now }
        current_filter = SearchFilter.get_filter(current_customer.customer_attribute.filter_id)
        unless current_filter.to_param
          current_customer.customer_attribute.update_attributes(:filter_id => nil) if current_customer
          cookies.delete :filter_id
        end
        if !options.empty?
          current_filter.update_with_defaults(options)
        end
      else
        current_filter = SearchFilter.get_filter(nil)
        current_filter.update_with_defaults(options)
        cookies[:filter_id] = { :value => current_filter.to_param, :expires => 1.year.from_now }
        current_customer.customer_attribute.update_attributes(:filter_id => current_filter.to_param) if current_customer
      end
    end
    current_filter
  end

  def check_host
    @jacob = 1
    if request.host.include? 'public'
      ENV['HOST_OK'] = "1"
    else
      ENV['HOST_OK'] = "0"
    end
    params[:host_nl] = nederlands? ? true : false 
    #ENV['HOST_OK'] = "1"
  end

  def no_param
    (request.parameters['controller'] == 'products' and (params[:id].nil? && params[:sort] == "normal" && params[:view_mode].nil? && params[:list_id].nil? && params[:category_id].nil? &&  params[:actor_id].nil? && params[:director_id].nil? && params[:studio_id].nil? && params[:search].nil? && params[:studio_id].nil? && params[:filter_id].nil?))
  end

  def send_message(mail_id, options, customer_default = nil)
    customer = customer_default ? customer_default : current_customer
    mail_object = Email.by_language(I18n.locale).find(mail_id)
    recipient = Rails.env != 'development' ? customer.email : 'it@dvdpost.be'
    if customer.customer_attribute.mail_copy || mail_object.force_copy
      mail_history= MailHistory.create(:date => Time.now().to_s(:db), :customers_id => customer.to_param, :mail_messages_id => mail_id, :language_id => DVDPost.customer_languages[I18n.locale], :customers_email_address=> customer.email)
      options["\\$\\$\\$mail_messages_sent_history_id\\$\\$\\$"] = mail_history.to_param
    else
      options["\\$\\$\\$mail_messages_sent_history_id\\$\\$\\$"] = 0
    end
      list = ""
      options.each {|k, v|  list << "#{k.to_s.tr("\\","")}:::#{v};;;"}
      if customer.customer_attribute.mail_copy || mail_object.force_copy
        email_data_replace(mail_object.subject, options)
        subject = email_data_replace(mail_object.subject, options)
        message = email_data_replace(mail_object.body, options)
        mail_history.update_attributes(:lstvariable => list)
        Emailer.deliver_send(recipient, subject, message)
      end
      @ticket = Ticket.new(:customer_id => customer.to_param, :category_ticket_id => mail_object.category_id)
      @ticket.save
      if mail_history
        @message = MessageTicket.new(:ticket => @ticket, :mail_id => mail_id, :data => list, :user_id => 55, :mail_history_id => mail_history.to_param)
      else
        @message = MessageTicket.new(:ticket => @ticket, :mail_id => mail_id, :data => list, :user_id => 55)
      end
      @message.save
  end

  def product_reviews_count(product)
    if product.imdb_id == 0
      product.reviews.approved.by_language(I18n.locale).count
    else  
      Review.by_imdb_id(product.imdb_id).approved.by_language(I18n.locale).find(:all, :joins => :product).count
    end
  end

  def streaming_free(product)
    return {:status => false, :available => false} if ENV['HOST_OK'] == "1" || product.nil?
    streaming_free = StreamingProductsFree.by_imdb_id(product.imdb_id).available.first
    if streaming_free
      if streaming_free.kind = DVDPost.streaming_free_type[:beta_test] 
        if current_customer.beta_test && current_customer.abo_active == 0
          if current_customer.tokens.all(:joins => :streaming_products_free, :conditions =>  ['streaming_products_free.available = 1 and streaming_products_free.available_from < ? and streaming_products_free.expire_at > ?', Time.now.localtime.to_s(:db), Time.now.localtime.to_s(:db)]).count == 0
            {:status => true, :available => true} #streaming free not use
          else
            {:status => true, :available => false} #streaming free but this customer have already use his free movie
          end
        else
          {:status => false, :available => false} #streaming free but this customer dont have access
        end
      else
        {:status => true, :available => true} # streaming free for all
      end
    else
      {:status => false, :available => false} #streaming not free
    end
  end

  def promotion(customer, text = false)
    product_abo = customer.product_abo
    product_next_abo = customer.product_next_abo
    product_next = customer.product_next
    credits = product_next_abo.credits
  	rotation = product_next_abo.qty_at_home
  	price_abo = product_next.products_price

    promo_type = product_abo.credits == 0 ? :unlimited : :freetrial
    if customer.promo_type == 'D'
      discount = customer.discount
      credits_promo = discount.credits > 0 ? discount.credits : credits
      case discount.duration_type
      when 1
        period = t 'promotion.promo_day', :duration => discount.duration_value, :credits => credits_promo
        duration = t 'promotion.duration_day', :duration => discount.duration_value
      when 2
        period = t 'promotion.promo_month', :duration => discount.duration_value, :credits => credits_promo
        duration = t 'promotion.duration_month', :duration => discount.duration_value
      when 3
        period = t 'promotion.promo_year', :duration => discount.duration_value, :credits => credits_promo
        duration = t 'promotion.duration_year', :duration => discount.duration_value
      end
    elsif customer.promo_type == 'A'
      activation = customer.activation
  		credits_promo = activation.credits > 0 ? activation.credits : credits
   		promo_type = :pre_paid if activation.activation_waranty == 2
   		case activation.duration_type
  		when 1
        period = t 'promotion.promo_day', :duration => activation.duration_value, :credits => credits_promo
        duration = t 'promotion.duration_month', :duration => activation.duration_value
      when 2
        period = t 'promotion.promo_month', :duration => activation.duration_value, :credits => credits_promo
        duration = t 'promotion.duration_month', :duration => activation.duration_value
      when 3
        period = t 'promotion.promo_year', :duration => activation.duration_value, :credits => credits_promo
        duration = t 'promotion.duration_year', :duration => activation.duration_value
      end
    end
    period_next = t 'promotion.promo_next', :credits => credits, :rotation => rotation, :price => price_abo
    if customer.promo_type != 'D' && customer.promo_type != 'A'
      return {:promo => nil , :promo_next => nil}
    end
    if promo_type == :pre_paid
      return {:promo => period , :promo_next => period_next}
    else
      if promo_type != :unlimited
        if customer.promo_price > 0
          return text ? {:promo => t('promotion.paid_promo', :period => period, :price => customer.promo_price), :promo_next => period_next} : {:promo => period, :promo_next => period_next}
        else
          return text ? {:promo => t('promotion.trial', :period => period), :promo_next => period_next} : {:promo => period, :promo_next => period_next}
        end
      else
        return {:promo => t('promotion.unlimited', :duration => duration, :credits => credits_promo), :promo_next => period_next}
      end
    end
  end

  def login_path
    
    prefix = mobile_request? ? "http://m." : "http://"
    path = params[:page_name] == 'error' ? session[:error_path] ? session[:error_path] : root_path : request.fullpath 
    path = path.include?('?') ? "#{path}&login=1" : "#{path}?login=1"
    
    case Rails.env
      when "production"
        if request.host_with_port.include?('dvdpost.nl')
          "#{prefix}private.dvdpost.nl#{path}"
        else
          "#{prefix}private.dvdpost.com#{path}"
        end
      when "pre_production"
        "#{prefix}beta.dvdpost.com#{path}"
      when "staging"
        "#{prefix}staging.private.dvdpost.com#{path}"
      when "development"
        if request.host_with_port.include?('dvdpost.nl')
          "#{prefix}private.dvdpost.nl#{path}"
        else
          "#{prefix}private.dvdpost.dev#{path}"
        end
    end
  end

  def body_classes(subdomains =  nil)
    name = [controller.controller_name].join(' ')
    
    name = name + '_show' if controller.controller_name.to_s == 'products' && controller.action_name.to_s == 'show'
    name = name + '_' + subdomains if subdomains
    name
  end

  def t_nl(value, options = {})
    if nederlands?
      t("#{value}_nl", :default => '').empty? ? t("#{value}", options) :  t("#{value}_nl", options)
    else
      t("#{value}", options)
    end
  end

  def format_text(browser)
    if browser.windows?
      "pc"
    elsif browser.mac?
      "mac"
    elsif browser.iphone?
      "iphone"
    elsif browser.ipad?
      "ipad"
    elsif browser.ipod?
      "ipod"
    elsif browser.tablet?
      "tablet"
    elsif browser.mobile?
      "mobile"
    else
      "other"
    end
  end

  def price_format(price)
    res = price.to_s.match(/([0-9]*).([0-9]*)/)
    "<span class='integer'>#{res[1]}</span>.<span class='decimal'>#{res[2]}</span>"
  end
end