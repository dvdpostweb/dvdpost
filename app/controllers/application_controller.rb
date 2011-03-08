# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'
require 'rss/2.0'
require 'geo_ip'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  helper_method :current_customer

  before_filter :save_attempted_path
  before_filter :check_host
  before_filter :authenticate!, :unless => :is_special_page?
  before_filter :wishlist_size
  before_filter :indicator_close?
  before_filter :delegate_locale
  before_filter :messages_size, :unless => :is_it_js?
  before_filter :load_partners, :unless => :is_it_js?
  before_filter :redirect_after_registration
  before_filter :set_locale_from_params
  before_filter :set_country
  before_filter :get_wishlist_source
  before_filter :last_login, :unless => :is_it_js?
  

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

  def is_special_page?
    test = ENV['HOST_OK'] == "1" && (request.parameters['page_name'] == 'get_connected' || ( request.parameters['controller'] == 'streaming_products' && request.parameters['action'] == 'faq') || ( request.parameters['controller'] == 'search_filters') || (request.parameters['controller'] == 'products' ) || request.parameters['controller'] == 'themes' || ( request.parameters['controller'] == 'reviews' && request.parameters['action'] == 'index'))
    return test
  end

  def set_locale_from_params
    locale = extract_locale_from_params
    locale = current_customer.update_locale(locale) if current_customer
    set_locale(locale || :fr)
  end

  def last_login
    if current_customer
      if !session[:last_login]
        current_customer.last_login
        session[:last_login] = true
      end
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

  def set_country
    if session[:country_code].nil? || session[:country_code].empty?
      begin
        GeoIp.api_key = DVDPost.geo_ip_key
        geo = GeoIp.geolocation(request.remote_ip, {:precision => :country})
        country_code = geo[:country_code]
        session[:country_code] = country_code
        if country_code.nil? || country_code.empty?
          notify_hoptoad("country code is empty ip : #{request.remote_ip}")
        end
      rescue => e
        notify_hoptoad("geo_ip gem generate a error : #{e} ip #{request.remote_ip}")
      end
    else
      country_code = session[:country_code]
    end
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
    "#{I18n.locale.to_s}/home/recommendations/customers/#{current_customer.to_param}"
  end

  def retrieve_recommendations(page, options = {})
    fragment_name = fragment_name_by_customer
    Product.search()
    recommendation_items_serialize = when_fragment_expired fragment_name, 1.hour.from_now do
      
      begin
        Marshal.dump(current_customer.recommendations(get_current_filter(options),options))
      rescue => e
        logger.error "Homepage recommendations unavailable: #{e.message}"
        expire_fragment_with(fragment_name)
        false
      end
    end
    recommendation_items = Marshal.load(recommendation_items_serialize)
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
      HoptoadNotifier.notify(:error_message => "GeoIP error : #{message}")
    rescue => e
      logger.error("GeoIP error: #{message}")
      logger.error(e.backtrace)
    end
  end
  
end

