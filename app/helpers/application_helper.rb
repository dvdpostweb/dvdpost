# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  protected
  def switch_locale_link(locale, options=nil)
    if params['controller'] == "home" && params['action'] == "index"
      link_to t(".#{locale}"), root_path(params.merge(:locale => locale)), options
    else
      link_to t(".#{locale}"), params.merge(:locale => locale), options
    end
  end

  def product_media_id(media)
    case media
      when 'DVD', 'HDD', 'PS3', 'Wii' then media.downcase
      when 'BlueRay'                  then 'bluray'
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

  def redirect_after_registration
    if current_customer && current_customer.customers_registration_step.to_i != 100  && current_customer.customers_registration_step.to_i != 95
      redirect_to php_path
    end
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
      params[:kind] = 'normal'
    end
    #if params[:locale].nil?
    #  set_locale('fr')
    #else
    #  set_locale(params[:locale])
    #end
  end

  def messages_size
    @messages_size = (current_customer.tickets.find(:all, :include => :message_tickets, :conditions =>  ["message_tickets.`is_read` = 0 and message_tickets.user_id > 0"]).count || 0) if current_customer
  end

  def load_partners
    @partners = Partner.active.by_language(I18n.locale).ordered
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

  def oauth_token
    session[:oauth_token] ? OAuth2::AccessToken.new(oauth_client, session[:oauth_token]) : nil
  end

  def redirect_url_after_sign_out
    php_path
  end

  def blog_url
    "http://insidedvdpost.blogspot.com/"
  end

  def fb_url
    "http://www.facebook.com/dvdpost"
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

  def product_shop_path(product)
    php_path "product_info_shop.php?products_id=#{product.to_param}"
  end

  def product_public_path(product)
    "http://public.dvdpost.com/#{I18n.locale}/products/#{product.to_param}"
  end

  def my_shop_path
    php_path 'mydvdshop.php'
  end

  def remote_carousel_path(carousel)
    php_path carousel
  end

  def shop_path(url)
    php_path url
  end

  def production_path(country_id=nil)
    if current_customer
      if country_id.to_i == 21 || country_id.to_i == 124 || country_id == nil
        'http://www.dvdpost.be/'
      else
        'http://www.dvdpost.nl/'
      end
    else
      if session[:country_code] == 'NL'
        'http://www.dvdpost.nl/'
      else
        'http://www.dvdpost.be/'
      end
    end
  end

  def product_assigned_path(product)
    if product
      if product.adult?
        product_path(:kind => :adult, :id => product.to_param)
      else
        product_path(:kind => :normal, :id => product.to_param)
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
      text = text.gsub(r, value)
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
    distance_of_time_in_hours((stream.updated_at + hours_left.hours), Time.now)
  end

  def streaming_access?
    !current_customer || ((current_customer.address && current_customer.address.belgian? && (session[:country_id] == 22 || session[:country_id] == 0)) || current_customer.super_user?)
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
    if (request.host == 'public.dvdpost.com') || (request.host == 'staging.public.dvdpost.com') 
      ENV['HOST_OK'] = "1"
    else
      ENV['HOST_OK'] = "0"
    end
    ENV['HOST_OK'] = "1"
  end

  def no_param
    (request.parameters['controller'] == 'products' and (params[:id].nil? && params[:sort] == "normal" && params[:view_mode].nil? && params[:list_id].nil? && params[:category_id].nil? &&  params[:actor_id].nil? && params[:director_id].nil? && params[:studio_id].nil? && params[:search].nil? && params[:studio_id].nil?))
  end

  def send_message(mail_id, options)
    mail_object = Email.by_language(I18n.locale).find(mail_id)
    recipient = current_customer.email
    if current_customer.customer_attribute.mail_copy
      mail_history= MailHistory.create(:date => Time.now().to_s(:db), :customers_id => current_customer.to_param, :mail_messages_id => mail_id, :language_id => DVDPost.customer_languages[I18n.locale], :customers_email_address=> current_customer.email)
      options["\\$\\$\\$mail_messages_sent_history_id\\$\\$\\$"] = mail_history.to_param
    else
      options["\\$\\$\\$mail_messages_sent_history_id\\$\\$\\$"] = 0
    end
      list = ""
      options.each {|k, v|  list << "#{k.to_s.tr("\\","")}:::#{v};;;"}
      if current_customer.customer_attribute.mail_copy
        email_data_replace(mail_object.subject, options)
        subject = email_data_replace(mail_object.subject, options)
        message = email_data_replace(mail_object.body, options)
        mail_history.update_attributes(:lstvariable => list)
        Emailer.deliver_send(recipient, subject, message)
      end
      @ticket = Ticket.new(:customer_id => current_customer.to_param, :category_ticket_id => mail_object.category_id)
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

end