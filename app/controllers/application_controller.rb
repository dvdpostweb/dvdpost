# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'open-uri'
require 'rss/2.0'
require 'geo_ip'
require 'db_charmer'
require 'extend_string'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  include ApplicationHelper

  protect_from_forgery # See ActionController::RequestForgeryProtection for details
    #before_filter :http_authenticate, :if => :staging?
    helper_method :current_customer, :unless => :is_it_xml?
    before_filter :save_attempted_path, :unless => :is_it_xml?
    before_filter :check_host
    before_filter :authenticate!, :unless => :is_special_page?
    before_filter :delegate_locale, :if => :is_it_html?
    #before_filter :set_mobile_preferences
    before_filter :redirect_to_mobile_if_applicable
    #before_filter :prepend_view_path_if_mobile

    before_filter :redirect_after_registration, :unless => :is_it_xml?
    before_filter :set_locale_from_params
    before_filter :set_country, :unless => :is_it_xml?
    before_filter :get_wishlist_source, :unless => :is_it_xml?
    before_filter :last_login, :if => :is_it_html?
    #before_filter :theme_actif, :if => :is_it_html?
    before_filter :validation_adult, :if => :is_it_html?
    before_filter :sexuality?
    before_filter :public_behaviour, :if => :public_page?
    before_filter :allow_cross_domain_access
  rescue_from ::ActionController::MethodNotAllowed do |exception|
    logger.warn "*** #{exception} Path: #{request.path} ***"
    render :file => "#{Rails.root}/public/404.html", :status => 404
  end

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  protected
  def staging?
    Rails.env == 'staging' || Rails.env == 'pre_production'
  end
  # Force all mobile users to login
  def mobile_request?
    return request.subdomains.first == "m"
  end
  helper_method :mobile_request?

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
      @themes = ThemesEvent.old.hp.by_kind(params[:kind]).ordered.limit(2)
      @theme = ThemesEvent.selected_beta.by_kind(params[:kind]).first
      unless @theme
        theme_actif_production
      end
    else
      theme_actif_production
    end
  end

  def is_special_page?
    test = ENV['HOST_OK'] == "1" && (request.parameters['page_name'] == 'get_connected' ||  request.parameters['page_name'] == 'promo' || ( request.parameters['controller'] == 'streaming_products') || ( request.parameters['controller'] == 'search_filters') || (request.parameters['controller'] == 'products' ) || (request.parameters['controller'] == 'home' ) || request.parameters['controller'] == 'themes_events' || request.parameters['controller'] == 'newsletters' || request.parameters['action'] == 'unsubscribe' || (request.parameters['controller'] == 'phone_requests') || ( request.parameters['controller'] == 'messages' && request.parameters['action'] == 'faq') || ( request.parameters['controller'] == 'reviews' && (request.parameters['action'] == 'index' || request.parameters['action'] == 'show')) || request.parameters['controller'] == 'info' || request.parameters['controller'] == 'categories' || request.parameters['controller'] == 'studios' || (request.parameters['controller'] == 'home' && request.parameters['action'] == 'validation') || request.parameters['controller'] == 'actors' || request.parameters['controller'] == 'chronicles' || request.parameters['controller'] == 'public_newsletters' || request.parameters['controller'] == 'public_promotions' || request.parameters['controller'] == 'customers_svods')
  end

  def set_locale_from_params
    if ENV['HOST_OK'] == "1" && params[:url_promo]
      cookies[:url_promo] = { :value => params[:url_promo], :expires => 1.week.from_now, :domain => request.domain }
    end
    if ENV['HOST_OK'] == "1" && params[:all]
      cookies[:adult_hide] = { :value => 1, :expires => 1.year.from_now, :domain => request.domain }
    end

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
    if params[:kind] == :adult && !session[:adult] && params[:code].nil? && params['action'] != 'validation' && params['action'] != 'authenticate'
      prefix = "http://"
      session['current_uri'] = prefix + request.host_with_port + request.request_uri
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
    user_agent = request.env['HTTP_USER_AGENT'] ? request.env['HTTP_USER_AGENT'].downcase : ''
    @bot = [ 'msnbot', 'yahoo! slurp', 'googlebot', 'baidu', 'majestic', 'rambler', 'abachobot', 'accoona', 'aspseek', 'croccrawler', 'dumbot', 'fast-webcrawler'].detect { |bot| user_agent.include? bot }
    if params[:debug_country_id]
      session[:country_id] = params[:debug_country_id].to_i
    elsif current_customer && current_customer.id == 1086213
      session[:country_id] = 22
      session[:my_ip] = request.remote_ip
    else
      my_ip = request.remote_ip
      if session[:country_id].nil? || session[:country_id] == 77 || session[:my_ip] != my_ip
        ip_regex = /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/
        my_forwarded_ip = request.env["HTTP_X_FORWARDED_FOR"] if !ip_regex.match(request.env["HTTP_X_FORWARDED_FOR"]).nil? && ! /^192(.*)/.match(request.env["HTTP_X_FORWARDED_FOR"]) && ! /^172(.*)/.match(request.env["HTTP_X_FORWARDED_FOR"]) && ! /^10\.(.*)/.match(request.env["HTTP_X_FORWARDED_FOR"])
        cf = GeoIP.new('GeoIP.dat').country(my_forwarded_ip) if my_forwarded_ip
        c = GeoIP.new('GeoIP.dat').country(my_ip)

        if c.country_code == 0 && Rails.env == "production" && ! /^192(.*)/.match(my_ip) && ! /^172(.*)/.match(my_ip) && ! /^10(.*)/.match(my_ip) && ! /^127(.*)/.match(my_ip)
          notify_hoptoad("country code is empty ip : #{my_ip}")
        end
        if cf && (cf.country_code == 22 || cf.country_code == 161 || cf.country_code == 131)
          session[:country_id] = cf.country_code
          session[:my_ip] = my_forwarded_ip
        else
          session[:country_id] = c.country_code
          session[:my_ip] = my_ip
        end
      end
    end
    if current_customer && (current_customer.id == 20618 || current_customer.id == 20618)
      begin
        ip_regex = /^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$/
        my_forwarded_ip = request.env["HTTP_X_FORWARDED_FOR"] if !ip_regex.match(request.env["HTTP_X_FORWARDED_FOR"]).nil? && ! /^192(.*)/.match(request.env["HTTP_X_FORWARDED_FOR"]) && ! /^172(.*)/.match(request.env["HTTP_X_FORWARDED_FOR"]) && ! /^10\.(.*)/.match(request.env["HTTP_X_FORWARDED_FOR"])
        cf = GeoIP.new('GeoIP.dat').country(my_forwarded_ip) if my_forwarded_ip
        c = GeoIP.new('GeoIP.dat').country(request.remote_ip)
        message = "#{request.session_options[:id]} session country #{session[:country_id]} session ip #{session[:my_ip]} ip #{request.remote_ip} forwarded ip #{request.env["HTTP_X_FORWARDED_FOR"]} country code #{c.country_code} country code fowarded #{cf ? cf.country_code : ''}"
        recipient = 'it@dvdpost.be'
        subject = "audit geolocalisation for customer id  mars 04 #{current_customer.id}"
        Emailer.deliver_send(recipient, subject, message)
      rescue => e
        logger.error("GeoIP error: ip #{request.remote_ip} forwarded ip #{request.env["HTTP_X_FORWARDED_FOR"]}")
        logger.error(e.backtrace)
      end
    end

    #session[:country_id] = 0
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


  private
    def public_page?
      ENV['HOST_OK'] == "1"
    end

    def public_behaviour
      if !params[:promo].nil?
        session[:promo] = params[:promo]
      end
      if !params[:code].nil?
        session[:code] = params[:code]
      end
      if !params[:later].nil?
        session[:later] = "later"
        cookies[:nb_pages_views] =  { :value => 0, :expires => 3.months.from_now }
      end
      if session[:later] != "later"
        if cookies[:nb_pages_views].nil?
          cookies[:nb_pages_views] = { :value => 1, :expires => 3.months.from_now }
        else
          cookies[:nb_pages_views] = { :value => cookies[:nb_pages_views].to_i + 1, :expires => 3.months.from_now }
        end
      end
      if params[:controller] == 'products' && params[:action] == 'show'
        id = params[:id].gsub(/-.*/,'')
        if cookies[:products_seen].nil?
          cookies[:products_seen] = { :value => id, :expires => 10.year.from_now }
        else
          unless products_seen_read.include?(id)
            cookies[:products_seen] = { :value => cookies[:products_seen] << ",#{id}", :expires => 3.months.from_now }
          end
        end
        unless cookies[:public_newsletter_id].nil?
          news = PublicNewsletter.find(cookies[:public_newsletter_id])
          news.public_newsletter_products.destroy_all
          products_seen_read.each do |product|
            news.public_newsletter_products.create(:product_id =>product)
          end
        end
      end
      return nil
    end

    def products_seen_read
      return cookies[:products_seen] ? cookies[:products_seen].split(",") : []
    end

    def set_mobile_preferences
      if params[:mobile_site]
        cookies.delete(:prefer_full_site)
      elsif params[:full_site]
        cookies.permanent[:prefer_full_site] = 1
        redirect_to_full_site if mobile_request?
      end
    end

    def redirect_to_full_site
      redirect_to request.protocol + request.host_with_port.gsub(/^m\./, '') +
                  request.request_uri  and return
    end

    def redirect_to_mobile_if_applicable

      @browser = Browser.new(:ua => request.user_agent, :accept_language => "en-us")
      #if params[:mobile_site]
      #  redirect_to request.protocol + "m." + request.host_with_port and return
      #else
      #  unless mobile_request? || cookies[:prefer_full_site] || !@browser.mobile? || browser.iphone? || browser.ios? || browser.tablet?
      #    redirect_to request.protocol + "m." + request.host_with_port + request.request_uri and return
      #  end
      #end
    end
  def prepend_view_path_if_mobile
    if mobile_request?
      mobile_path = Rails.root.join("app", "views_mobile").to_s
      prepend_view_path(mobile_path)
    end
  end

  def http_authenticate
    authenticate_or_request_with_http_basic do |id, password|
      id == 'dvdpostadmin' && password == 'Chase-GiorgioMoroder@dvdpost'
    end
    warden.custom_failure! if performed?
  end

  def notify_hoptoad(message)
    begin
      Airbrake.notify(:error_message => "GeoIP error : #{message}", :backtrace => $@, :environment_name => ENV['RAILS_ENV'])
    rescue => e
      logger.error("GeoIP error: #{message}")
      logger.error(e.backtrace)
    end
  end

  def allow_cross_domain_access
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "*"
  end

end
