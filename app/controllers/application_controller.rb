# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'
require 'rss/2.0'
require 'geo_ip'
require 'db_charmer'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
    helper_method :current_customer, :unless => :is_it_xml?
    before_filter :save_attempted_path, :unless => :is_it_xml?
    before_filter :check_host
    before_filter :authenticate!, :unless => :is_special_page?
    before_filter :delegate_locale, :if => :is_it_html?
    before_filter :load_partners, :if => :is_it_html?
    before_filter :redirect_after_registration, :unless => :is_it_xml?
    before_filter :set_locale_from_params
    before_filter :set_country, :unless => :is_it_xml?
    before_filter :get_wishlist_source, :unless => :is_it_xml?
    before_filter :last_login, :if => :is_it_html?
    before_filter :theme_actif, :if => :is_it_html?
    before_filter :validation_adult, :if => :is_it_html?
    before_filter :sexuality?

  rescue_from ::ActionController::MethodNotAllowed do |exception|
    logger.warn "*** #{exception} Path: #{request.path} ***"
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  
  protected


  def is_it_js?
    request.format.js?
  end

  def is_it_xml?
    request.format.xml?
  end

  def is_it_html?
    !request.format.js? && !request.format.xml?
  end

  def theme_actif
    if Rails.env == "pre_production"
      @theme = ThemesEvent.selected_beta.by_kind(params[:kind]).last
      unless @theme
        @theme = ThemesEvent.selected.by_kind(params[:kind]).last
      end
    else
      @theme = ThemesEvent.selected.by_kind(params[:kind]).last
    end
  end

  def theme_actif_hp
    if Rails.env == "pre_production"
      theme_hp = ThemesEvent.selected_beta.hp.by_kind(params[:kind]).last
      unless theme_hp
        theme_hp = ThemesEvent.selected.hp.by_kind(params[:kind]).last
      end  
      return theme_hp
    else
      return ThemesEvent.selected.hp.by_kind(params[:kind]).last
    end
  end

  def is_special_page?
    test = ENV['HOST_OK'] == "1" && (request.parameters['page_name'] == 'get_connected' ||  request.parameters['page_name'] == 'promo' || ( request.parameters['controller'] == 'streaming_products') || ( request.parameters['controller'] == 'search_filters') || (request.parameters['controller'] == 'products' ) || request.parameters['controller'] == 'themes' || ( request.parameters['controller'] == 'reviews' && request.parameters['action'] == 'index') || request.parameters['controller'] == 'info')
    return test
  end

  def set_locale_from_params
    locale = extract_locale_from_params
    locale = current_customer.update_locale(locale) if ENV['HOST_OK'] == "0" && current_customer
    set_locale(locale || :fr)
    #I18n.locale = 'en'
  end

  def last_login
    if current_customer
      if !session[:last_login]
        current_customer.last_login(:normal)
        session[:last_login] = true
      end
      if !session[:last_login_adult] && session[:adult]
        current_customer.last_login(:adult)
        session[:last_login_adult] = true
      end
      
    end
  end

  def validation_adult
    if params[:kind] == :adult && !session[:adult] && params['action'] != 'validation' && params['action'] != 'authenticate'
      session['current_uri'] = request.env['PATH_INFO']
      redirect_to validation_path
    end
  end

  def get_wishlist_source
    @wishlist_source = {}
    wl_source = WishlistSource.find(:all)
    wl_source.each do |item|
      @wishlist_source[item.name.downcase.to_sym] = item.to_param
    end
  end

  def indicator_close?
    @indicator_close = false
    if current_customer && current_customer.customer_attribute && current_customer.customer_attribute.list_indicator_close == true
        @indicator_close = true
    end
  end

  def sexuality?
    if !session[:sexuality]
      if current_customer && current_customer.customer_attribute && current_customer.customer_attribute.sexuality == 1
        session[:sexuality] = 1
      else
        session[:sexuality] = 0
      end
    end
  end

  def set_country
   # if session[:country_code].nil? || session[:country_code].empty?
   #   begin
   #     GeoIp.api_key = DVDPost.geo_ip_key
   #     geo = GeoIp.geolocation(request.remote_ip, {:precision => :country})
   #     country_code = geo[:country_code]
   #     session[:country_code] = country_code
   #     if country_code.nil? || country_code.empty?
   #       notify_hoptoad("country code is empty ip : #{request.remote_ip}")
   #     end
   #   rescue => e
   #     notify_hoptoad("geo_ip gem generate a error : #{e} ip #{request.remote_ip}")
   #   end
   # else
   #   country_code = session[:country_code]
   # end
   session[:country_code] = 'BE'
   country_code = 'BE'
  end
  
  def available_locales
    AVAILABLE_LOCALES
  end

  def extract_locale_from_params
    locale = params[:locale].to_sym unless params[:locale].blank?
    locale if available_locales.include?(locale)
  end

  def default_url_options(options={})
    options.keys.include?(:locale) ? options : options.merge(:locale => I18n.locale)
  end

  def expiration_recommendation_cache()
    fragment_name = fragment_name_by_customer
    expire_fragment(fragment_name)
  end

  def fragment_name_by_customer()
    if current_customer
      "#{I18n.locale.to_s}/home/recommendations/customers/#{current_customer.to_param}"
    else
      "#{I18n.locale.to_s}/home/recommendations/public"
    end
  end

  def retrieve_recommendations(page, options = {})
    fragment_name = fragment_name_by_customer
    Product.search()
    recommendation_items_serialize = when_fragment_expired fragment_name, 1.hour.from_now do
      begin
        if current_customer
          Marshal.dump(current_customer.recommendations(get_current_filter(options),options))
        else
            
          Marshal.dump(recommendation_public(options))
        end
      rescue => e
        logger.error "Homepage recommendations unavailable: #{e.message}"
        expire_fragment(fragment_name)
        false
      end        
    end
    if recommendation_items_serialize
      recommendation_items = Marshal.load(recommendation_items_serialize)
    else
      recommendation_items = if current_customer
        current_customer.recommendations(get_current_filter(options),options)
      else
       recommendation_public(options)
      end
      expire_fragment(fragment_name_by_customer)
    end
    if recommendation_items
      data = recommendation_items.paginate(:per_page => 8, :page => page)
      page = params[:recommendation_page].to_i
      while data.size == 0 && page > 1
        page = page - 1
        data = recommendation_items.paginate(:per_page => 8, :page => page)
      end
      data
    else
      nil
    end
  end

  private
  def http_authenticate
    authenticate_or_request_with_http_basic do |id, password|
      id == 'dvdpostadmin' && password == 'Chase-GiorgioMoroder@dvdpost'
    end
    warden.custom_failure! if performed?
  end
  
  def notify_hoptoad(message)
    begin
      Airbrake.notify(:error_message => "GeoIP error : #{message}")
    rescue => e
      logger.error("GeoIP error: #{message}")
      logger.error(e.backtrace)
    end
  end
  
  def recommendation_public(options)
    filter = get_current_filter({})
    recommendation_ids = DVDPost.home_page_recommendations(999999999)
    results = if recommendation_ids
      filter.update_attributes(:recommended_ids => recommendation_ids)
      options.merge!(:subtitles => [2]) if I18n.locale == :nl
      options.merge!(:audio => [1]) if I18n.locale == :fr
      Product.filter(filter, options.merge(:view_mode => :recommended))
    else
      []
    end
  end
  
end