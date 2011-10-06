class Movie < ActiveRecord::Base
  establish_connection "development2"

  belongs_to :director, :primary_key => :id
  belongs_to :studio
  belongs_to :country, :class_name => 'ProductCountry', :foreign_key => :country_id
  has_one :public, :primary_key => :public_id, :foreign_key => :public_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_many :descriptions, :class_name => 'MovieDescription'
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :categories
  has_many :products
  has_many :ratings
  has_many :movie_seen
  has_many :trailers
  has_many :reviews
  belongs_to :movie_kind
  #has_and_belongs_to_many :product_lists, :join_table => :listed_products, :order => 'listed_products.order asc'
  #has_and_belongs_to_many :soundtracks, :join_table => :products_to_soundtracks, :foreign_key => :products_id, :association_foreign_key => :products_soundtracks_id

  named_scope :normal_available, :conditions => ['movie_kind_id = :kind and status != :status', { :kind => DVDPost.movie_kinds[:normal], :status => '-1'}]
  named_scope :adult_available,  :conditions => ['movie_kind_id = :kindand status != :status', { :kind => DVDPost.movie_kinds[:adult], :status => '-1'}]
  named_scope :both_available, :conditions => ['status != :status', {:status => '-1'}]
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :ordered, :order => 'id desc'

  define_index do
    indexes descriptions.name,  :as => :descriptions_text, :sortable => true
    indexes director.name,            :as => :director_name
    indexes actors.name,                 :as => :actors_name

    has categories(:id), :as => :category_id
    has actors(:id),         :as => :actors_id
    has director(:id),         :as => :directors_id
    has products.languages(:id), :as => :language_ids
    has season_id
    has movie_kind_id
    has "case 
      when season_id > 0 and movie_type_id = 2 then season_id
      else movies.id + 1000000 end", :type  => :integer, :as => :real_season_id
    #has availability
    has country_id
    #has available_at
    has dvdpost_choice
    #has id
    #has "next", :type  => :integer, :as => :next
    has public_id,            :as => :audience
    has year
    has dvdpost_rating
    has imdb_id
    has in_cinema_now
    #has collections(:themes_id),    :as => :collection_id
    #has studio(:studio_id),         :as => :studio_id
    #has product_lists(:id),         :as => :products_list_ids
    #has "CAST(listed_products.order AS SIGNED)", :type => :integer, :as => :special_order
    #has subtitles(:undertitles_id), :as => :subtitle_ids
    has 'cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1))', :type => :float, :as => :rating
    #has streaming_products(:imdb_id), :as => :streaming_imdb_id
    #has "min(streaming_products.id)", :type => :integer, :as => :streaming_id
    #has streaming_products(:available_from), :as => :available_from
    #has streaming_products(:expire_at), :as => :expire_at
    #has 'cast((SELECT count(*) FROM `wishlist_assigned` wa WHERE wa.products_id = products.products_id and date_assigned > date_sub(now(), INTERVAL 1 MONTH) group by wa.products_id) AS SIGNED)', :type => :integer, :as => :most_viewed
    #has 'cast((SELECT count(*) FROM `wishlist_assigned` wa WHERE wa.products_id = products.products_id and date_assigned > date_sub(now(), INTERVAL 1 YEAR) group by wa.products_id) AS SIGNED)', :type => :integer, :as => :most_viewed_last_year
    
    #has "(select created_at s from streaming_products where imdb_id = products.imdb_id order by id desc limit 1)", :type => :datetime, :as => :streaming_created_at
    
    has "(select hex(replace(replace(replace(replace(replace(replace (replace(replace(replace(replace(replace (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace (replace(replace(replace(replace(replace(lower(name),char(0xe6),'ae'),char(0xe9),'e'),char(0xe7),'c'),char(0xe0),'a'),char(0xf6),'o'),char(0xe8),'e'),char(0xf4),'o'),char(0xeb),'e'),char(0xea),'e'),char(0xee),'i'),char(0xef),'i'),char(0xf9),'u'),char(0xfb),'u'),char(0xe0),'a'),char(0xe4),'a'), char(0xfa),'u'),char(0xe2),'a'),char(0xf3),'o'),char(0xe1),'a'),char(0xed),'i'),char(0xf1),'n'),char(0xe5),'a'),char(0xe4),'a'),char(0xfc),'u'),char(0xf2),'o'),char(0xec),'i'))  AS name_ord from movie_descriptions pd where  language_id = 1 and pd.movie_id = movies.id)", :type => :string, :as => :descriptions_title_fr
    has "(select hex(replace(replace(replace(replace(replace(replace (replace(replace(replace(replace(replace (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace (replace(replace(replace(replace(replace(lower(name),char(0xe6),'ae'),char(0xe9),'e'),char(0xe7),'c'),char(0xe0),'a'),char(0xf6),'o'),char(0xe8),'e'),char(0xf4),'o'),char(0xeb),'e'),char(0xea),'e'),char(0xee),'i'),char(0xef),'i'),char(0xf9),'u'),char(0xfb),'u'),char(0xe0),'a'),char(0xe4),'a'), char(0xfa),'u'),char(0xe2),'a'),char(0xf3),'o'),char(0xe1),'a'),char(0xed),'i'),char(0xf1),'n'),char(0xe5),'a'),char(0xe4),'a'),char(0xfc),'u'),char(0xf2),'o'),char(0xec),'i'))  AS name_ord from movie_descriptions pd where  language_id = 2 and pd.movie_id = movies.id)", :type => :string, :as => :descriptions_title_nl
    has "(select hex(replace(replace(replace(replace(replace(replace (replace(replace(replace(replace(replace (replace(replace(replace(replace(replace(replace(replace(replace(replace(replace (replace(replace(replace(replace(replace(lower(name),char(0xe6),'ae'),char(0xe9),'e'),char(0xe7),'c'),char(0xe0),'a'),char(0xf6),'o'),char(0xe8),'e'),char(0xf4),'o'),char(0xeb),'e'),char(0xea),'e'),char(0xee),'i'),char(0xef),'i'),char(0xf9),'u'),char(0xfb),'u'),char(0xe0),'a'),char(0xe4),'a'), char(0xfa),'u'),char(0xe2),'a'),char(0xf3),'o'),char(0xe1),'a'),char(0xed),'i'),char(0xf1),'n'),char(0xe5),'a'),char(0xe4),'a'),char(0xfc),'u'),char(0xf2),'o'),char(0xec),'i'))  AS name_ord from movie_descriptions pd where  language_id = 3 and pd.movie_id = movies.id)", :type => :string, :as => :descriptions_title_en
    
    #has "case 
    #when products_media = 'DVD' and streaming_products.imdb_id is not null and streaming_products.available_from < now() and streaming_products.expire_at > now() and streaming_products.status = 'online_test_ok' then 2
    #when products_media = 'VOD' and streaming_products.imdb_id is not null and streaming_products.available_from < now() and streaming_products.expire_at > now() and streaming_products.status = 'online_test_ok' then 5
    #when products_media = 'DVD' then 1 
    #when products_media = 'blueray' and streaming_products.imdb_id is not null and streaming_products.available_from < now() and streaming_products.expire_at > now() and streaming_products.status = 'online_test_ok' then 4 
    #when products_media = 'blueray' then 3
    #else 6 end", :type  => :integer, :as => :special_media
    #has "case 
    #when  streaming_products.available_from < now() and streaming_products.expire_at > now() and streaming_products.status = 'online_test_ok' then 1
    #else 0 end", :type => :integer, :as => :streaming_available
    #has "case 
    #when  streaming_products.available_from < now() and streaming_products.expire_at > now() then 1
    #else 0 end", :type => :integer, :as => :streaming_available_test
    #has "(select count(*) c from tokens where tokens.imdb_id = products.imdb_id and (datediff(now(),created_at) < 8))", :type => :integer, :as => :count_tokens
    #has "case
    #when products_date_available > DATE_SUB(now(), INTERVAL 8 MONTH) and products_date_available < DATE_SUB(now(), INTERVAL 2 MONTH) and products_series_id = 0 and cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) >= 3 and products_quantity > 0 then 1
    #when products_date_available < DATE_SUB(now(), INTERVAL 8 MONTH) and products_series_id = 0 and cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) >= 4 and products_quantity > 2 then 1
    #else 0 end", :type => :integer, :as => :popular
    #has 'concat(if(products_quantity>0,1,0),date_format(products_date_available,"%Y%m%d"))', :type => :integer, :as => :default_order
    has "case 
    when  status = -1 then 99
    else status end", :type => :integer, :as => :status
    #has products_quantity,          :type => :integer, :as => :in_stock
    has season_id,          :type => :integer, :as => :series_id
    set_property :enable_star => true
    set_property :min_prefix_len => 3
    set_property :charset_type => 'sbcs'
    set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
    set_property :ignore_chars => "U+AD"
    #set_property :field_weights => {:brand_name => 10, :name_fr => 5, :name_nl => 5, :description_fr => 4, :description_nl => 4}
  end

  sphinx_scope(:by_actor)           {|actor|            {:with =>       {:actors_id => actor.to_param}}}
  sphinx_scope(:by_director)        {|director|            {:with =>       {:directors_id => director.to_param}}}
  sphinx_scope(:by_category)        {|category|         {:with =>       {:category_id => category.to_param}}}
  sphinx_scope(:group)              {|group,sort|       {:group_by => group, :group_function => :attr, :group_clause   => sort}}
  
  #sphinx_scope(:by_products_id)     {|products_id|      {:with =>       {:id => products_id}}}
  #sphinx_scope(:exclude_products_id){|products_id|      {:without =>    {:id => products_id}}}
  sphinx_scope(:by_audience)        {|min, max|         {:with =>       {:audience => Public.legacy_age_ids(min, max)}}}
  #sphinx_scope(:by_collection)      {|collection|       {:with =>       {:collection_id => collection.to_param}}}
  #sphinx_scope(:hetero)             {{:without =>       {:category_id => 76}}}
  #sphinx_scope(:gay)                {{:with =>          {:category_id => 76}}}
  sphinx_scope(:by_country)         {|country|          {:with =>       {:country_id => country.to_param}}}
  #sphinx_scope(:by_studio)          {|studio|           {:with =>       {:studio_id => studio.to_param}}}
  sphinx_scope(:by_imdb_id)         {|imdb_id|          {:with =>       {:imdb_id => imdb_id}}}
  sphinx_scope(:by_language)        {|language|         {:order =>      language.to_s == 'fr' ? :french : :dutch, :sort_mode => :desc}}
  sphinx_scope(:by_kind)            {|kind|             {:with => {:movie_kind_id => DVDPost.movie_kinds[kind]}}}
  #sphinx_scope(:by_media)           {|media|            {:conditions => {:products_media => media}}}
  #sphinx_scope(:by_special_media)   {|media|            {:with =>       {:special_media => media}}}
  sphinx_scope(:by_period)          {|min, max|         {:with =>       {:year => min..max}}}
  #sphinx_scope(:by_products_list)   {|product_list|     {:with =>       {:products_list_ids => product_list.to_param}}}
  sphinx_scope(:by_ratings)         {|min, max|         {:with =>       {:rating => min..max}}}
  #sphinx_scope(:by_recommended_ids) {|recommended_ids|  {:with =>       {:id => recommended_ids}}}
  sphinx_scope(:with_languages)     {|language_ids|     {:with =>       {:language_ids => language_ids}}}
  #sphinx_scope(:with_subtitles)     {|subtitle_ids|     {:with =>       {:subtitle_ids => subtitle_ids}}}
  sphinx_scope(:available)          {{:without =>       {:status => [99]}}}
  sphinx_scope(:dvdpost_choice)     {{:with =>          {:dvdpost_choice => 1}}}
  sphinx_scope(:recent)             {{:without =>       {:availability => 0}, :with => {:available_at => 2.months.ago..Time.now, :next => 0, :dvdpost_rating => 3..5}}}
  sphinx_scope(:cinema)             {{:with =>          {:in_cinema_now => 1, :next => 1, :dvdpost_rating => 3..5}}}
  sphinx_scope(:soon)               {{:with =>          {:in_cinema_now => 0, :next => 1, :dvdpost_rating => 3..5}}}
  #sphinx_scope(:streaming)          {{:without =>       {:streaming_imdb_id => 0}, :with => {:streaming_available => 1}}}
  #sphinx_scope(:streaming_test)     {{:without =>       {:streaming_imdb_id => 0}, :with => {:streaming_available_test => 1}}}
  sphinx_scope(:random)             {{:order =>         '@random'}}
  #sphinx_scope(:popular_new)        {{:with =>          {:popular => 1}}}
  #sphinx_scope(:weekly_streaming)   {{:without =>       {:streaming_imdb_id => 0}, :with => {:streaming_created_at => 7.days.ago..Time.now, :streaming_available => 1 }}}
  
  sphinx_scope(:popular)            {{:with =>          {:available_at => 8.months.ago..2.months.ago, :rating => 3.0..5.0, :series_id => 0, :in_stock => 3..1000}}}
  #sphinx_scope(:popular_streaming)  {{:without =>       {:streaming_imdb_id => 0, :count_tokens =>0}, :with => {:streaming_available => 1 }}}
  sphinx_scope(:not_recent)         {{:with =>          {:next => 0}}}
  sphinx_scope(:by_serie)           {|serie_id|         {:with => {:series_id => serie_id}}}
  
  sphinx_scope(:order)              {|order, sort_mode| {:order => order, :sort_mode => sort_mode}}
  
  sphinx_scope(:limit)              {|limit|            {:limit => limit}}

  def self.filter(filter, options={})
    products = search_clean(options[:search], {:page => options[:page], :per_page => options[:per_page]})
    products = products.by_products_list(options[:list_id]) if options[:list_id] && !options[:list_id].blank?
    products = products.by_actor(options[:actor_id]) if options[:actor_id]
    products = products.by_category(options[:category_id]) if options[:category_id]
    products = products.by_collection(options[:collection_id]) if options[:collection_id]
    products = products.hetero if options[:hetero]
    products = products.by_director(options[:director_id]) if options[:director_id]
    products = products.by_studio(options[:studio_id]) if options[:studio_id]
    products = products.by_audience(filter.audience_min, filter.audience_max) if filter.audience? && options[:kind] == :normal
    products = products.by_country(filter.country_id) if filter.country_id?
    #products = products = products.by_special_media([2,4,5]) if options[:filter] && options[:filter] == "vod"
    #products = products = products.by_special_media([1,2]) if options[:filter] && options[:filter] == "dvd"
    #products = products = products.by_special_media([3,4]) if options[:filter] && options[:filter] == "bluray"
    
    #if filter.media? && options[:kind] == :normal
    #  
    #  medias = filter.media.dup
    #  if medias.include?(:dvd)
    #    if medias.include?(:bluray)
    #      if medias.include?(:streaming)
    #        medias = [1,2,3,4]
    #      else
    #        medias = [1,3]
    #      end
    #    elsif medias.include?(:streaming)
    #      medias = [1,2,5]
    #    else
    #      medias = [1,2]
    #    end
    #  elsif medias.include?(:bluray)
    #    if medias.include?(:streaming)
    #      medias = [2,3,4,5]
    #    else
    #      medias = [3,4]
    #    end
    #  elsif medias.include?(:streaming)
    #    medias = [2,4,5]
    #  end
    #  products = products.by_special_media(medias)
    #end
    products = products.by_ratings(filter.rating_min.to_f, filter.rating_max.to_f) if filter.rating?
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
        if Rails.env == "production"
          products.streaming
        else
          products.streaming_test
        end
      when :weekly_streaming
        products.weekly_streaming
      when :popular_streaming
          products.streaming.limit(10)
      when :recommended
        products.by_recommended_ids(filter.recommended_ids)
      when :popular
        products.popular_new.limit(800)
      else
        products
      end
    end
    if options[:sort] && options[:sort].to_sym == :new
      products = products.not_recent
    end
    if options[:kind] == :adult
      products = products.by_kind(:adult).available
    else
      products = products.by_kind(:normal).available
    end

    #if options[:list_id] && !options[:list_id].blank?
    #  sort = sort_by("special_order asc", options)
    #elsif options[:search] && !options[:search].blank?
    #  sort = sort_by("", options)
    #elsif options[:view_mode] && options[:view_mode].to_sym == :streaming
    #  sort = sort_by("streaming_id desc", options)
    #elsif options[:view_mode] && options[:view_mode].to_sym == :streaming
    #  sort = sort_by("streaming_id desc", options)
    #elsif options[:view_mode] && options[:view_mode].to_sym == :popular_streaming
    #  sort = sort_by("count_tokens desc, streaming_id desc", options)
    #elsif options[:view_mode] && options[:view_mode].to_sym == :popular
    #  sort = sort_by("available_at DESC, rating desc", options)
    #elsif options[:view_mode] && (options[:view_mode].to_sym == :recent || options[:view_mode].to_sym == :weekly_streaming)
    #  sort = sort_by("available_at desc", options)
    #elsif options[:view_mode] && (options[:view_mode].to_sym == :soon || options[:view_mode].to_sym == :cinema)
    #  sort = sort_by("available_at asc", options)
    #else
    #  sort = sort_by("default_order desc, in_stock DESC", options)
    #end
    #if sort !=""
    #  if options[:view_mode] && (options[:view_mode].to_sym == :streaming || options[:view_mode].to_sym == :popular_streaming || options[:view_mode].to_sym == :weekly_streaming )
    #    products = products.group('imdb_id', sort)
    #  else
    #    products = products.order(sort, :extended)
    #  end
    #end
    products = products.group('real_season_id', 'season_id desc')
    products
    # products = products.sphinx_order('listed_products.order asc', :asc) if params[:top_id] && !params[:top_id].empty?
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

  def description
      descriptions.by_language(I18n.locale).first
  end

  def description_data(full = false)
    if desc = description
      title = desc.title
      if movie_kind_id == DVDPost.movie_kinds[:adult]
        image = File.join(DVDPost.imagesx_path, desc.image)  if !desc.image.blank?
      else
        image =  File.join(DVDPost.images_path, desc.image) if !desc.image.blank?
      end
      if full
        description = desc
      else
        description = nil
      end
        
    else
      title = products_title
      image = nil
      description = nil
    end
    {:image => image, :title => title, :description => description}
  end

  def streaming?
    products.by_support(:vod).count > 0
  end

  def trailer
    localized_trailers = trailers.by_language(I18n.locale.to_s)
    localized_trailers ? localized_trailers.first : nil
  end

  def vod?
    #media == DVDPost.product_types[:vod]
    false
  end
  def adult?
    movie_kind_id == DVDPost.movie_kinds[:adult]
  end

  def title
    if desc = description
      desc.title
    else
      name
    end
  end

  def image
    if desc = description
      if movie_kind_id == DVDPost.movie_kinds[:adult]
        File.join(DVDPost.imagesx_path, desc.image)  if !desc.image.blank?
      else
        File.join(DVDPost.images_path, desc.image) if !desc.image.blank?
      end
    end
  end  

  def rating(customer=nil)
    if customer && customer.has_rated?(self)
      ratings.by_customer(customer).first.value.to_i * 2
    else
      rating_count == 0 ? 0 : ((rating_users.to_f / rating_count) * 2).round
    end
  end

  def dvdposts_choice?
    dvdpost_choice == 1
  end

  def adult?
    movie_kind_id == DVDPost.movie_kinds[:adult]
  end

end
