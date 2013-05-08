module DVDPost
  class << self
    def images_path
      'http://www.dvdpost.be/images'
    end

    def imagesx_path
      'http://www.dvdpost.be/imagesx'
    end

    def imagesx_preview_path
      'http://www.dvdpost.be/imagesx/screenshots'
    end

    def images_preview_path
      'http://www.dvdpost.be/images/screenshots'
    end

    def imagesx_trailer_path
      'http://www.dvdpost.be/imagesx/trailers'
    end

    def images_trailer_path
      'http://www.dvdpost.be/images/trailers'
    end

    def imagesx_banner_path
      'http://www.dvdpost.be/imagesx/banners'
    end

    def images_banner_path
      'http://www.dvdpost.be/images/banners'
    end

    def images_carousel_path
      "#{images_path}/landings"
    end

    def images_carousel_adult_path
      "#{imagesx_path}/landings"
    end

    def itunes_url(lang)
      "http://itunes.apple.com/be/app/dvdpost/id504412426?l=#{lang}&mt=8"
    end

    def airplay_url
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.apple.com/befr/appletv/airplay/',
        :nl => 'http://www.apple.com/benl/appletv/airplay/',
        :en => 'http://www.apple.com/uk/appletv/airplay/'
      })
    end

    def appletv_url
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.apple.com/befr/appletv/',
        :nl => 'http://www.apple.com/benl/appletv/',
        :en => 'http://www.apple.com/uk/appletv//'
      })
    end

    def iphone_url
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.apple.com/befr/iphone/',
        :nl => 'http://www.apple.com/benl/iphone/',
        :en => 'http://www.apple.com/uk/iphone/'
      })
    end

    def ipad_url
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.apple.com/befr/ipad/',
        :nl => 'http://www.apple.com/benl/ipad/',
        :en => 'http://www.apple.com/uk/ipad/'
      })
    end

    def news_url
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://syndication.cinenews.be/rss/newsfr.xml',
        :nl => 'http://syndication.cinenews.be/rss/newsnl.xml',
        :en => 'http://www.cinemablend.com/rss.php'
      })
    end

    def images_language_path
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.dvdpost.be/images/www3/languages/french/images',
        :nl => 'http://www.dvdpost.be/images/www3/languages/dutch/images',
        :en => 'http://www.dvdpost.be/images/www3/languages/english/images'
      })
    end

    def images_shop_path
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.dvdpost.be/images/www3/languages/french/images/shop',
        :nl => 'http://www.dvdpost.be/images/www3/languages/dutch/images/shop',
        :en => 'http://www.dvdpost.be/images/www3/languages/english/images/shop'
      })
    end

    def banner_size
      HashWithIndifferentAccess.new.merge({
        :small => '180x150'
      })
    end

    def product_languages
      HashWithIndifferentAccess.new.merge({
        :fr => 1,
        :nl => 2,
        :en => 3
      })
    end

    def list_languages
      HashWithIndifferentAccess.new.merge({
        :fr => 0,
        :nl => 1,
        :en => 2
      })
    end

    def customer_languages
      HashWithIndifferentAccess.new.merge({
        :fr => 1,
        :nl => 2,
        :en => 3
      })
    end

    def product_publics
      HashWithIndifferentAccess.new.merge({
        'all' => 1,
        '6' => 5,
        '10' => 6,
        '12' => 2,
        '14' => 7,
        '16' => 3,
        '18' => 4
      })
    end

    def local_product_publics
      product_publics.invert
    end

    def news_kinds
      HashWithIndifferentAccess.new.merge({
        :normal => 'NORMAL',
        :adult => 'ADULT',
      })
    end

    def search_kinds
      HashWithIndifferentAccess.new.merge({
        :normal => 'normal',
        :adult => 'adult',
      })
    end

    def product_kinds
      HashWithIndifferentAccess.new.merge({
        :normal => 'DVD_NORM',
        :adult => 'DVD_ADULT',
        :subscription => 'ABO'
      })
    end

    def actor_kinds
      HashWithIndifferentAccess.new.merge({
        :normal => 'DVD_NORM',
        :adult => 'DVD_ADULT'
      })
    end

    def actor_kinds_int
      HashWithIndifferentAccess.new.merge({
        :normal => 1,
        :adult => 0
      })
    end

    def products_special_types
      HashWithIndifferentAccess.new.merge({
        :dvd => 1,
        :streaming_dvd => 2,
        :bluray => 3,
        :streaming_bluray => 4
      })
    end

    def product_types
      HashWithIndifferentAccess.new.merge({
        :dvd => 'DVD',
        :bluray => 'BlueRay',
        :bluray3d => 'bluray3d',
        :bluray3d2d => 'bluray3d2d',
        :vod => 'VOD',
        :hdd => 'HDD',
        :ps3 => 'PS3',
        :wii => 'Wii',
        :xbox => 'XBOX 360'
      })
    end

    def home_review_types
      HashWithIndifferentAccess.new.merge({
        :best_rate => 'BEST_RATE',
        :best_review => 'BEST_REVIEW',
        :controverse_rate => 'CONTROVERSE_RATE',
        :best_customer => 'BEST_CUSTOMER'
      })
    end

    def trailer_broadcasts_urls
      HashWithIndifferentAccess.new.merge({
        'DAYLYMOTION' => 'http://www.dailymotion.com/video/',
        'YOUTUBE' => 'http://www.youtube.com/watch?v=',
        'TRUVEO' => 'http://www.truveo.com/_slug_/id/' # => There is a slug for this url: http://www.truveo.com/backstage-trailer-1/id/1191367212
      })
    end

    def wishlist_priorities
      HashWithIndifferentAccess.new.merge({
        :high => 1,
        :medium => 2,
        :low => 3
      })
    end

    def payment_methods
      HashWithIndifferentAccess.new.merge({
        :credit_card => 1,
        :domicilation => 2
      })
    end

    def streaming_free_type
      HashWithIndifferentAccess.new.merge({
        :beta_test => 'BETA_TEST',
        :all => 'ALL'
      })
    end

    def home_page_news
      open(news_url[I18n.locale]) do |http|
        RSS::Parser.parse(http.read, false).items
      end
    end

    def url_suspension
      'webservice/suspend.php'
    end

    def send_suspension(customer_id,duration,host)
      xml = "#{host}&customer_id=#{customer_id}&type=HOLIDAYS&duration=#{duration}&user_id=55"
      doc = Hpricot(open(xml))
      status = (doc/'root').each do|st|
        error = (st/'error').inner_html
        status = (st/'status').inner_html
        return status
      end
      return status
    end

    def cinopsis_critics(imdb_id)
      text = ""
      open("http://www.cinopsis.be/dvdpost_test.cfm?imdb_id=#{imdb_id}") do |data|
        Hpricot(Iconv.conv('UTF-8', data.charset, data.read)).search('//p').each do|data| 
          text << "<p>#{data.innerHTML}</p>"  
        end
      end
    end

    def product_linked_recommendations(product, kind, language)
      include_adult = kind == :adult ? 'DVD_ADULT' : 'DVD_NORM' 
      #url = "http://partners.thefilter.com/DVDPostService/RecommendationService.ashx?cmd=DVDRecommendDVDs&id=#{product.id}&number=30&includeAdult=#{include_adult}"
      url = Rails.env == "production" ? "http://api181.thefilter.com/dvdpost/live/video(#{product.id})/recommendation/video?$take=30&$filter=availability%20gt%200.1%20AND%20genre%20eq%20#{include_adult}" : "http://api182.thefilter.com/dvdpost/sandbox/video(#{product.id})/recommendation/video?$take=30&$filter=availability%20gt%200.1%20AND%20genre%20eq%20#{include_adult}"
      unless kind == :adult
        case language
        when :fr
          url += "%20AND%20language%20eq%20French"
        when :en
          url += "%20AND%20language%20eq%20English"
        when :nl
          url += "%20AND%20subTitleLanguage%20eq%20Dutch"
        end
      end
      data = open url
      hp = Hpricot(data)
      dvd_id = hp.search('//item').collect{|dvd| dvd.attributes['id'].to_i}
      response_id = hp.search("response").first.attributes['responseid']
      {:dvd_id => dvd_id, :response_id => response_id, :url => url}
    end

    def product_linked_recommendations_new(product, kind, customer_id, type)
      include_adult = kind == :adult ? 'true' : 'false'
      url = "http://www.dvdpost.be:2348/recomm/#{type == 1 ? 'GetSimilarMovieToProducts' : 'GetMovieToProductsByRating'}?imdbID=#{product.imdb_id}&isAdult=#{include_adult}"
      url += "&custId=#{customer_id}" if customer_id > 0
      ids = open(url).read.gsub('"','').split(',')
    end

    def home_page_recommendations_new(customer_id, kind)
      include_adult = kind == :adult ? 'true' : 'false'
      url = "http://www.dvdpost.be:2348/recomm/GetCustomerRecommendedProducts?custId=#{customer_id}&nmbr=8000&isAdult=#{include_adult}"
      ids = open(url).read.gsub('"','').split(',')
    end

    def home_page_recommendations(customer_id, language)
      #url = "http://partners.thefilter.com/DVDPostService/RecommendationService.ashx?cmd=UserDVDRecommendDVDs&id=#{customer_id}&number=100&includeAdult=false&verbose=false"
      url = Rails.env == "production" ? "http://api181.thefilter.com/dvdpost/live/video/recommendation/video?$take=100&extUserId=#{customer_id}&$filter=" : "http://api182.thefilter.com/dvdpost/sandbox/video/recommendation/video?$take=100&extUserId=#{customer_id}&$filter="
      case language
      when :fr
        url += "language%20eq%20French"
      when :en
        url += "language%20eq%20English"
      when :nl
        url += "subTitleLanguage%20eq%20Dutch"
      end
      data = open url
      hp = Hpricot(data)
      dvd_id = hp.search('//item').collect{|dvd| dvd.attributes['id'].to_i}
      response_id = hp.search("response").first.attributes['responseid']
      {:dvd_id => dvd_id, :response_id => response_id, :url => url}
    end

    def send_evidence_recommendations(type, product_id, customer, ip, params = nil, args = nil)
      #url = "http://partners.thefilter.com/DVDPostService/CaptureService.ashx?cmd=AddEvidence&eventType=#{type}&userLanguage=#{I18n.locale.to_s.upcase}&clientIp=#{ip}&userId=#{customer.to_param}&catalogId=#{product_id}"
      url = Rails.env == "production" ? "http://api181.thefilter.com/dvdpost/live/video(#{product_id})/Event/#{type}" : "http://api182.thefilter.com/dvdpost/sandbox/video(#{product_id})/Event/#{type}"
      url = "#{url}#{args.collect{|key,value| "/#{value}"}}" if args
      if customer
        url = "#{url}?extUserId=#{customer.to_param}" 
      else 
        url = "#{url}?"
      end
      url = "#{url}#{params.collect{|key,value| "&#{key}=#{value}" if !value.nil? && !value.empty?}}" if params
      #url
      open(url)
      return url
    end

    def product_dvd_statuses
      statuses = OrderedHash.new
      statuses.push(:unreadable, {:message => 3, :message_category => 1, :product_status => 2, :compensation => true})
      statuses.push(:broken, {:message => 22, :message_category => 2, :product_status => 4, :compensation => true})
      statuses.push(:damaged, {:message => 11, :message_category => 11, :product_status => 2, :compensation => false})
      statuses.push(:lost, {:message => 12, :message_category => 14, :product_status => 6, :compensation => false})
      statuses.push(:delayed, {:message => 5, :message_category => 3, :product_status => 5, :compensation => false, :order_status => 17, :at_home => false})
      statuses.push(:delayed_return, {:message => 7, :message_category => 5, :product_status => 5, :compensation => false, :order_status => 18, :at_home => false})
      statuses.push(:envelope, {})
      statuses.push(:arrived, {:message => 20, :message_category => 19, :product_status => 1, :compensation => false, :order_status => 2, :at_home => true})
      statuses
    end

    def messages_kind
      kind = OrderedHash.new
      kind.push(:number,        {:message => 18, :category => 16})
      kind.push(:billing_price, {:message => 13, :category => 9})
      kind.push(:billing_dvd,   {:message => 14, :category => 10})
      kind.push(:dom,           {:message => 16, :category => 13})
      kind
    end
  
    def email
      HashWithIndifferentAccess.new.merge({
        :sponsorships_invitation    => 446,
        :sponsorships_son           => 447,
        :streaming_product          => 571,
        :streaming_product_free     => 585,
        :message_free               => 578,
        :welcome                    => 556,
        :lavenir                   => 560
      })
    end

    def flash_player_link
      'http://get.adobe.com/fr/flashplayer/'
    end

    def image_stack
      HashWithIndifferentAccess.new.merge({
        :high => 'indicator-bg_green.png',
        :medium => 'indicator-bg_orange.png',
        :low => 'indicator-bg_red.png'
      })
    end
    
    def dvdpost_ip
      HashWithIndifferentAccess.new.merge({
        :external => ['217.112.190.73', '217.112.190.101', '217.112.190.177', '217.112.190.178', '217.112.190.179', '217.112.190.180', '217.112.190.181', '217.112.190.182','217.112.190.100','217.112.185.121','109.88.0.197','109.88.0.198','194.78.222.212','213.181.46.204','109.88.0.199','91.183.57.165','87.65.39.92','94.139.62.121','94.139.62.120','94.139.62.123','94.139.62.122'],
        :internal => '127.0.0.1'
      })
    end
    
    def dvdpost_super_user
      [203165,1068898,1072027,1034787,128570,1074454]
    end
    
    def geo_ip_key
      'c90802746715bfeb0fc6abd2f822174f994f03ca68d61a70944e6e66c4b6f617'
    end

    def streaming_poll_url
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.surveymonkey.com/s/vod_fr',
        :nl => 'http://www.surveymonkey.com/s/VNDHTYW',
        :en => 'http://www.surveymonkey.com/s/L87SHPF'
      })
    end
    
    def fb_url
      HashWithIndifferentAccess.new.merge({
        :fr => "http://www.facebook.com/dvdpost",
        :nl => "http://www.facebook.com/pages/DVDPost-NL/534236409942040",
        :en => "http://www.facebook.com/dvdpost"
      })
    end

    def analytics_code
      HashWithIndifferentAccess.new.merge({
        :public   => 'UA-7320293-1',
        :adult    => 'UA-8475379-1',
        :private  => 'UA-7319107-1',
        :all      => "UA-1121531-1"
      })
    end

    def message_categories
      HashWithIndifferentAccess.new.merge({
        :vod => 21,
      })
      
    end

    def bluray_link
      HashWithIndifferentAccess.new.merge({
        :fr => 'http://www.blurayfrance.net/definition-blu-ray.html',
        :nl => 'http://en.wikipedia.org/wiki/Blu-ray_Disc',
        :en => 'http://en.wikipedia.org/wiki/Blu-ray_Disc'
      })
    end

    def vod_file_size
      HashWithIndifferentAccess.new.merge({
        :hd => 2.8,
        :high => 1.8,
        :low => 1
      })
    end

    def mail_recommendation_dvd_to_dvd(customer_id, product_id, limit = 7)
      data = open("http://www.dvdpost.com/webservice/recommendations_dvd_to_dvd.php?product_id=#{product_id}&limit=#{limit}&customer_id=#{customer_id}").read
      Iconv.conv('utf-8','ISO-8859-1',  data)
    end

    def mail_movie_detail(customer_id, product_id, type = 'vod')
      data = open("http://www.dvdpost.com/webservice/movie_detail.php?product_id=#{product_id}&type=#{type}&customer_id=#{customer_id}").read
      Iconv.conv('utf-8','ISO-8859-1',  data)
    end

    def mail_vod_selection(customer_id, kind, limit = 7)
      data = open("http://www.dvdpost.com/webservice/vod_selection.php?limit=#{limit}&customer_id=#{customer_id}&kind=#{kind}").read
      Iconv.conv('utf-8','ISO-8859-1',  data)
    end

    def theme_adult
      9
    end

    def theme_versavenir
      23
    end

    def pen_points
      HashWithIndifferentAccess.new.merge({
        :one => 20,
        :two => 50,
        :three => 120,
        :four => 350,
        :five => 800
      })
    end
    
    def generate_token_from_alpha(filename, kind, test)
      if kind == :adult
        time = 720
      else
        time = 2880
      end
      
      url = "http://wesecure.alphanetworks.be/Webservice?method=createToken&key=acac0d12ed9061049880bf68f20519e65aa8ecb7&filename=#{filename}&lifetime=#{time}&simultIp=1&test=#{test}"
      data = open(url, :http_basic_authentication => ["dvdpost", "sup3rnov4$$"])
      node = Hpricot(data).search('//createtoken')
      if node.at('status').innerHTML == 'success'
        node.at('response').innerHTML
      else
        false
      end
    end

    def generate_free_token_from_alpha(filename)
      time = 2880
      url = "http://wesecure.alphanetworks.be/Webservice?method=createToken&key=acac0d12ed9061049880bf68f20519e65aa8ecb7&filename=#{filename}&lifetime=#{time}&simultIp=1&test=true"
      data = open(url, :http_basic_authentication => ["dvdpost", "sup3rnov4$$"])
      node = Hpricot(data).search('//createtoken')
      if node.at('status').innerHTML == 'success'
        node.at('response').innerHTML
      else
        false
      end
    end

    def list_styles
      HashWithIndifferentAccess.new.merge({
        :dvd => 'DVD',
        :bluray => 'BLURAY',
        :vod => 'STREAMING'
      })
    end

    def hours
      HashWithIndifferentAccess.new.merge({
        :adult => 12,
        :normal => 48,
      })
    end

    def token_sample
      HashWithIndifferentAccess.new.merge({
        :normal => '50b76fa9208545.59558089',
        :adult => '50b7700bdbe828.10392938'
      })
    end
    def data_sample
      HashWithIndifferentAccess.new.merge({
        :normal => {:imdb_id =>1, :product_id => 106535},
        :adult => {:imdb_id =>2, :product_id => 127276}
      })
    end

    def hls_url(token, audio, sub)
      "http://vod.dvdpost.be/#{token}_#{audio}_#{sub}.m3u8"
    end

    def favorite_dvd
      HashWithIndifferentAccess.new.merge({
        :fr    => 316,
        :nl    => 317,
        :en    => 318
      })
    end
    def favorite_vod
      HashWithIndifferentAccess.new.merge({
        :fr    => 319,
        :nl    => 320,
        :en    => 321
      })
    end
    
    def streaming_url
      "vod.dvdpost.be"
    end

    def code_promo_faq
      HashWithIndifferentAccess.new.merge({
        :fr    => 'PGVODF',
        :nl    => 'PGVODN',
        :en    => 'PGVOD'
      })
    end
    
  end
end