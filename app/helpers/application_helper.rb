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

  def localized_image_tag(source, options={})
    image_tag File.join(I18n.locale.to_s, source), options
  end

  def current_customer
    @current_user ||= if current_user
      # current user provided by Warden, returns a token in this case
      token = current_user
      json = token.get("/me")
      logger.info json
      id = JSON.parse(json)["id"]
      Customer.find(id)
    end
  end

  def wishlist_size
    @wishlist_size = (current_customer.wishlist_items.count || 0) if current_customer
  end

  def delegate_locale
    set_locale(params[:locale])
  end

  def messages_size
    @messages_size = (current_customer.messages.not_read.count || 0) if current_customer
  end

  def load_partners
    @partners = Partner.active.by_language(I18n.locale).ordered
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
    session[:token] ? OAuth2::AccessToken.new(oauth_client, session[:oauth_token]) : nil
  end

  def sso_sign_out_path
    "#{OAUTH[:site]}/logout"
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
end
