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

    def images_carousel_path
      "#{images_path}/landings"
    end

    def images_carousel_adult_path
      "#{imagesx_path}/landings"
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

    def product_linked_recommendations(product, kind)
      include_adult = kind == :adult ? 'true' : 'false' 
      url = "http://partners.thefilter.com/DVDPostService/RecommendationService.ashx?cmd=DVDRecommendDVDs&id=#{product.id}&number=30&includeAdult=#{include_adult}"
      open url do |data|
        Hpricot(data).search('//dvds').collect{|dvd| dvd.attributes['id'].to_i}
      end
    end

    def home_page_recommendations(customer_id)
      url = "http://partners.thefilter.com/DVDPostService/RecommendationService.ashx?cmd=UserDVDRecommendDVDs&id=#{customer_id}&number=100&includeAdult=false&verbose=false"
      open url do |data|
        Hpricot(data).search('//dvds').collect{|dvd| dvd.attributes['id'].to_i}
      end
    end

    def send_evidence_recommendations(type, product_id, customer, ip, args=nil)
      url = "http://partners.thefilter.com/DVDPostService/CaptureService.ashx?cmd=AddEvidence&eventType=#{type}&userLanguage=#{I18n.locale.to_s.upcase}&clientIp=#{ip}&userId=#{customer.to_param}&catalogId=#{product_id}"
      url = "#{url}&#{args.collect{|key,value| "#{key}=#{value}"}.join('&')}" if args
      Rails.env == "production" ? open(url) : url
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
        :streaming_product          => 571,
        :streaming_product_free     => 585,
        :message_free               => 578
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
        :external => ['217.112.190.73', '217.112.190.101', '217.112.190.177', '217.112.190.178', '217.112.190.179', '217.112.190.180', '217.112.190.181', '217.112.190.182','217.112.190.100'],
        :internal => '127.0.0.2'
      })
    end
    
    def dvdpost_super_user
      [206183,194064,1017617,203165]
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

    def pen_points
      HashWithIndifferentAccess.new.merge({
        :one => 20,
        :two => 50,
        :three => 120,
        :four => 350,
        :five => 800
      })
    end
    
    def generate_token_from_alpha(filename)
      url = "http://vod.dvdpost.be:8081/webservice?method=create&filename=#{filename}&lifetime=2880&simultIp=1"
     open url do |data|
       node = Hpricot(data).search('//create')
       if node.at('status').innerHTML == 'success'
         node.at('response').innerHTML
       else
          false
       end  
     end
    end

    def list_styles
      HashWithIndifferentAccess.new.merge({
        :dvd => 'DVD',
        :bluray => 'BLURAY',
        :vod => 'STREAMING'
      })
    end
  end
end