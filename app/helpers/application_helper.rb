# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  protected
  def switch_locale_link(locale, options=nil)
    link_to t(".#{locale}"), params.merge(:locale => locale), options
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
      when 0..10 then 'low'
      when 11..30 then 'medium'
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
    @wishlist_size = (current_customer.wishlist_items.count || 0) if current_customer
  end

  def delegate_locale
    if params[:locale].nil?
      set_locale('fr')
    else
      set_locale(params[:locale])
    end
  end

  def messages_size
    @messages_size = (current_customer.messages.not_read.count || 0) if current_customer
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
    "http://www.facebook.com/s.php?q=20460859834&sid=4587e86f26b471cb22ab4b18b3ec5047#/group.php?sid=4587e86f26b471cb22ab4b18b3ec5047&gid=20460859834"
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
    country_id = current_customer ? current_customer.addresses.first.entry_country_id : nil
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

  def sponsor_path
    php_path 'member_get_member.php'
  end

  def contest_path
    php_path 'contest.php'
  end

  def quizz_path
    php_path 'quizz.php'
  end

  def who_we_are_path
    php_path 'whoweare.php'
  end

  def press_path
    php_path 'presse.php'
  end

  def privacy_path
    php_path 'privacy.php'
  end

  def conditions_path
    php_path 'conditions.php'
  end

  def limited_subscription_change_path
    php_path 'subscription_change_limited.php'
  end

  def suspension_path
    php_path 'holiday_form.php'
  end

  def product_shop_path(product)
    php_path "product_info_shop.php?products_id=#{product.to_param}"
  end

  def payment_method_change_path(type=nil)
    path = php_path 'payment_method_change.php'
    type ? "#{path}&payment=#{type}" : path
  end

  def reconduction_path
    php_path 'basic_reconduction_info.php'
  end

  def urgent_messages_path
    php_path 'messages_urgent.php'
  end

  def adult_path
    php_path 'mydvdxpost.php'
  end

  def my_shop_path
    php_path 'mydvdshop.php'
  end

  def remote_carousel_path(carousel)
    php_path carousel
  end

  def customers_reviews_path(customer)
    php_path "reviews_member.php?custid=#{customer.to_param}"
  end

  def shop_path(url)
    php_path url
  end

  def production_path(country_id=nil)
    if country_id.to_i == 21 || country_id == nil
      'http://www.dvdpost.be/'
    else
      'http://www.dvdpost.nl/'
    end
  end

  def product_assigned_path(product)
    if product.products_type == DVDPost.product_kinds[:adult]
      php_path "product_info_adult.php?products_id=#{product.to_param}"
    else
      product_path(:id => product.to_param)
    end
  end

  def product_assigned_title(product)
    if product.products_type == DVDPost.product_kinds[:adult]
      t('wishlit_items.index.adult_title')
    else
      product.title
    end
  end
end
