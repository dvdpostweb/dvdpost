class Product < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 20

  set_primary_key :products_id

  alias_attribute :availability,    :products_availability
  alias_attribute :available_at,    :products_date_available
  alias_attribute :created_at,      :products_date_added
  alias_attribute :kind,            :products_type
  alias_attribute :media,           :products_media
  alias_attribute :original_title,  :products_title
  alias_attribute :product_type,    :products_product_type
  alias_attribute :rating,          :products_rating
  alias_attribute :runtime,         :products_runtime
  alias_attribute :series_id,       :products_series_id
  alias_attribute :year,            :products_year

  belongs_to :director, :foreign_key => :products_directors_id
  belongs_to :country, :class_name => 'ProductCountry', :foreign_key => :products_countries_id
  belongs_to :picture_format, :foreign_key => :products_picture_format, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_one :public, :primary_key => :products_public, :foreign_key => :public_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_many :descriptions, :class_name => 'ProductDescription', :foreign_key => :products_id
  has_many :ratings, :foreign_key => :products_id
  has_many :reviews, :foreign_key => :products_id
  has_many :trailers, :foreign_key => :products_id
  has_many :uninteresteds, :foreign_key => :products_id
  has_many :uninterested_customers, :through => :uninteresteds, :source => :customer, :uniq => true
  has_many :wishlist_items
  has_many :streaming_products, :foreign_key => :imdb_id, :primary_key => :imdb_id, :conditions => {:available => 1}
  has_and_belongs_to_many :actors, :join_table => :products_to_actors, :foreign_key => :products_id, :association_foreign_key => :actors_id
  has_and_belongs_to_many :categories, :join_table => :products_to_categories, :foreign_key => :products_id, :association_foreign_key => :categories_id
  has_and_belongs_to_many :languages, :join_table => 'products_to_languages', :foreign_key => :products_id, :association_foreign_key => :products_languages_id, :conditions => {:languagenav_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_and_belongs_to_many :product_lists, :join_table => :listed_products, :order => 'listed_products.order asc'
  has_and_belongs_to_many :soundtracks, :join_table => :products_to_soundtracks, :foreign_key => :products_id, :association_foreign_key => :products_soundtracks_id
  has_and_belongs_to_many :seen_customers, :class_name => 'Customer', :join_table => :products_seen, :uniq => true
  has_and_belongs_to_many :subtitles, :join_table => 'products_to_undertitles', :foreign_key => :products_id, :association_foreign_key => :products_undertitles_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}

  named_scope :normal_available, :conditions => ['products_status != :status AND products_type = :kind', {:status => '-1', :kind => DVDPost.product_kinds[:normal]}]

  define_index do
    indexes products_media
    indexes products_type
    indexes actors.actors_name,                 :as => :actors_name
    indexes director.directors_name,            :as => :director_name
    #indexes descriptions.products_description,  :as => :descriptions_text
    indexes descriptions.products_name,         :as => :descriptions_title

    has products_availability,      :as => :availability
    has products_countries_id,      :as => :country_id
    has products_date_available,    :as => :available_at
    has products_dvdpostchoice,     :as => :dvdpost_choice
    has products_id,                :as => :id
    has products_next,              :as => :next
    has products_public,            :as => :audience
    has products_status,            :as => :status
    has products_year,              :as => :year
    has products_language_fr,       :as => :french
    has products_undertitle_nl,     :as => :dutch
    has products_rating,            :as => :dvdpost_rating
    has imdb_id
    has in_cinema_now
    has actors(:actors_id),         :as => :actors_id
    has categories(:categories_id), :as => :category_id
    has director(:directors_id),    :as => :director_id
    has languages(:languages_id),   :as => :language_ids
    has product_lists(:id),         :as => :products_list_ids
    has "CAST(listed_products.order AS SIGNED)", :type => :integer, :as => :special_order
    has subtitles(:undertitles_id), :as => :subtitle_ids
    has 'CAST((rating_users/rating_count) AS SIGNED)', :type => :integer, :as => :rating
    has streaming_products(:imdb_id), :as => :streaming_imdb_id
    has streaming_products(:available_from), :as => :available_from
    has streaming_products(:expire_at), :as => :expire_at
    has "case 
    when products_media = 'DVD' and streaming_products.imdb_id is null then 1 
    when products_media = 'DVD' and streaming_products.imdb_id is not null then 2
    when products_media = 'blueray' and streaming_products.imdb_id is null then 3
    when products_media = 'blueray' and streaming_products.imdb_id is not null then 4 
    else 5 end", :type  => :integer, :as => :special_media
    set_property :enable_star => true
    set_property :min_prefix_len => 3
    set_property :charset_type => 'sbcs'
    set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
    set_property :ignore_chars => "U+AD"
    set_property :field_weights => {:brand_name => 10, :name_fr => 5, :name_nl => 5, :description_fr => 4, :description_nl => 4}
  end

  # There are a lot of commented lines of code in here which are just used for development
  # Once all scopes are transformed to Thinking Sphinx scopes, it will be cleaned up.
  sphinx_scope(:by_actor)           {|actor|            {:with =>       {:actors_id => actor.to_param}}}
  sphinx_scope(:by_audience)        {|min, max|         {:with =>       {:audience => Public.legacy_age_ids(min, max)}}}
  sphinx_scope(:by_category)        {|category|         {:with =>       {:category_id => category.to_param}}}
  sphinx_scope(:by_country)         {|country|          {:with =>       {:country_id => country.to_param}}}
  sphinx_scope(:by_director)        {|director|         {:with =>       {:director_id => director.to_param}}}
  sphinx_scope(:by_imdb_id)         {|imdb_id|          {:with =>       {:imdb_id => imdb_id}}}
  sphinx_scope(:by_language)        {|language|         {:order =>      language.to_s == 'fr' ? :french : :dutch, :sort_mode => :desc}}
  sphinx_scope(:by_kind)            {|kind|             {:conditions => {:products_type => DVDPost.product_kinds[kind]}}}
  sphinx_scope(:by_media)           {|media|            {:conditions => {:products_media => media}}}
  sphinx_scope(:by_special_media)   {|media|            {:with => {:special_media => media}}}
  sphinx_scope(:by_period)          {|min, max|         {:with =>       {:year => min..max}}}
  sphinx_scope(:by_products_list)   {|product_list|     {:with =>       {:products_list_ids => product_list.to_param}}}
  sphinx_scope(:by_ratings)         {|min, max|         {:with =>       {:rating => min..max}}}
  sphinx_scope(:by_recommended_ids) {|recommended_ids|  {:with =>       {:id => recommended_ids}}}
  sphinx_scope(:with_languages)     {|language_ids|     {:with =>       {:language_ids => language_ids}}}
  sphinx_scope(:with_subtitles)     {|subtitle_ids|     {:with =>       {:subtitle_ids => subtitle_ids}}}
  sphinx_scope(:available)          {{:with =>          {:status => [0,1]}}}
  sphinx_scope(:dvdpost_choice)     {{:with =>          {:dvdpost_choice => 1}}}
  sphinx_scope(:recent)             {{:without =>       {:availability => 0}, :with => {:available_at => 2.months.ago..Time.now, :next => 0, :dvdpost_rating => 3..5}}}
  sphinx_scope(:cinema)             {{:with =>          {:in_cinema_now => 1, :next => 1, :dvdpost_rating => 3..5}}}
  sphinx_scope(:soon)               {{:with =>          {:in_cinema_now => 0, :next => 1, :dvdpost_rating => 3..5}, :order => '@random'}}
  sphinx_scope(:streaming)          {{:without =>       {:streaming_imdb_id => 0 }}}
  sphinx_scope(:random)             {{:order =>         '@random'}}
  
  sphinx_scope(:order)              {|order, sort_mode| {:order => order, :sort_mode => sort_mode}}
  sphinx_scope(:limit)              {|limit|            {:limit => limit}}

  def self.filter(filter, options={})
    products = search_clean(options[:search], {:page => options[:page], :per_page => options[:per_page]})
    products = products.by_products_list(options[:list_id]) if options[:list_id] && !options[:list_id].blank?
    products = products.by_actor(options[:actor_id]) if options[:actor_id]
    products = products.by_category(options[:category_id]) if options[:category_id]
    products = products.by_director(options[:director_id]) if options[:director_id]
    products = products.by_audience(filter.audience_min, filter.audience_max) if filter.audience?
    products = products.by_country(filter.country_id) if filter.country_id?
    if filter.media? 
      
      medias = filter.media.dup
      if medias.include?(:dvd)
        if medias.include?(:bluray)
          if medias.include?(:streaming)
            medias = [1,2,3,4]
          else
            medias = [1,3]
          end
        elsif medias.include?(:streaming)
          medias = [1,2]
        else
          medias = [1,2]
        end
      elsif medias.include?(:bluray)
        if medias.include?(:streaming)
          medias = [3,4]
        else
          medias = [3,4]
        end
      elsif medias.include?(:streaming)
        medias = [2,4]
      end
      products = products.by_special_media(medias)
    end
    products = products.by_ratings(filter.rating_min, filter.rating_max) if filter.rating?
    products = products.by_period(filter.year_min, filter.year_max) if filter.year?
    if filter.audio?
      products = products.with_languages(filter.audio)
    else
      products = products.with_languages(options[:audio]) if options[:audio] 
    end
    if filter.subtitles?
      products = products.with_subtitles(filter.subtitles) 
    else
      products = products.with_subtitles(options[:subtitles]) if options[:subtitles] 
    end
    products = products.dvdpost_choice if filter.dvdpost_choice?
    if options[:view_mode]
      products = case options[:view_mode].to_sym
      when :recent
        products.recent
      when :soon
        products.soon
      when :cinema
        products.cinema
      when :streaming
        products.streaming
      when :recommended
        products.by_recommended_ids(filter.recommended_ids)
      else
        products
      end
    end
    if options[:list_id] && !options[:list_id].blank?
      products = products.by_kind(:normal).available.order(:special_order, :asc)
    elsif options[:search] && !options[:search].blank?
      products = products.by_kind(:normal).available
    elsif options[:view_mode] && options[:view_mode].to_sym == :streaming
      products = products.by_kind(:normal).available.order(:imdb_id, :desc)
    else
       products = products.by_kind(:normal).available.order(:id, :desc)
    end
    # products = products.sphinx_order('listed_products.order asc', :asc) if params[:top_id] && !params[:top_id].empty?
  end

  def recommendations
    begin
      # external service call can't be allowed to crash the app
      recommendation_ids = DVDPost.product_linked_recommendations(self)
    rescue => e
      logger.error("Failed to retrieve recommendations: #{e.message}")
    end
    self.class.find_all_by_products_id(recommendation_ids) if recommendation_ids
  end

  def description
    descriptions.by_language(I18n.locale).first
  end

  def title
    description ? description.title : products_title
  end

  def trailer
    localized_trailers = trailers.by_language(I18n.locale.to_s)
    localized_trailers ? localized_trailers.first : nil
  end

  def image
    File.join(DVDPost.images_path, description.image) if description && !description.image.blank?
  end

  def rating(customer=nil)
    if customer && customer.has_rated?(self)
      ratings.by_customer(customer).first.value.to_i * 2
    else
      rating_count == 0 ? 0 : ((rating_users.to_f / rating_count) * 2).round
    end
  end

  def rate!(value)
    update_attributes({:rating_count => (rating_count + 1), :rating_users => (rating_users + value)})
  end

  def is_new?
    availability > 0 && created_at < Time.now && available_at && available_at > 3.months.ago && products_next == 0
  end

  def dvdposts_choice?
    products_dvdpostchoice == 1
  end

  def dvd?
    media == DVDPost.product_types[:dvd]
  end

  def bluray?
    media == DVDPost.product_types[:bluray]
  end

  def series?
    products_series_id != 0
  end

  def available_to_sale?
    quantity_to_sale > 0
  end

  def streaming?
    streaming_products.count > 0
  end

  def good_language?(language)
    languages.find_by_languages_id(language) || subtitles.find_by_undertitles_id(language)
  end

  def views_increment
    # Dirty raw sql.
    # This could be fixed with composite_primary_keys but version 2.3.5.1 breaks all other associations.
    connection.execute("UPDATE products_description SET products_viewed = #{description.viewed + 1} WHERE (products_id = #{to_param}) AND (language_id = #{DVDPost.product_languages[I18n.locale]})")
    description.viewed
  end

  def media_alternative(media)
    self.class.available.by_kind(:normal).by_imdb_id(imdb_id).by_media([media]).by_language(I18n.locale).limit(1).first
  end

  def self.search_clean(query_string, options={})
    qs = []
    if query_string
      qs = query_string.split.collect do |word|
        "*#{replace_specials(word)}*".gsub(/[-_]/, ' ')
      end
    end
    query_string = qs.join(' ')

    page = options[:page] || 1
    per_page = options[:per_page] || self.per_page
    self.search(query_string, :max_matches => 100_000, :per_page => per_page, :page => page)
  end

  def self.replace_specials(str)
    str.mb_chars.normalize(:kd).gsub(/[^\x00-\x7F]/n, '').to_s
  end

  def self.notify_hoptoad(ghost)
    begin
      HoptoadNotifier.notify(:error_message => "Ghost record found: #{ghost.inspect}")
    rescue => e
      logger.error("Exception raised wihile notifying ghost record found: #{ghost.inspect}")
      logger.error(e.backtrace)
    end
  end
end
