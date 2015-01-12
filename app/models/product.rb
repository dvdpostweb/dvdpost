# encoding: utf-8
class Product < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  cattr_reader :per_page
  @@per_page = 20

  set_primary_key :products_id
  def self.table_name_prefix
    Rails.env == 'production' || Rails.env == 'pre_production' ? 'dvdpost_be_prod.' : 'dvdpost_test.'
  end
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
  alias_attribute :price,           :products_price
  alias_attribute :next,            :products_next
  alias_attribute :studio,          :products_studio
  alias_attribute :qty_sale,        :quantity_to_sale
  alias_attribute :price_sale,      :products_sale_price
  
  belongs_to :director, :foreign_key => :products_directors_id
  belongs_to :studio, :foreign_key => :products_studio
  belongs_to :country, :class_name => 'ProductCountry', :foreign_key => :products_countries_id
  belongs_to :picture_format, :foreign_key => :products_picture_format, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  belongs_to :serie, :foreign_key => :products_series_id
  has_one :public, :primary_key => :products_public, :foreign_key => :public_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_many :descriptions, :class_name => 'ProductDescription', :foreign_key => :products_id
  has_many :descriptions_fr, :class_name => 'ProductDescription', :foreign_key => :products_id, :conditions => {:language_id => 1}
  has_many :descriptions_nl, :class_name => 'ProductDescription', :foreign_key => :products_id, :conditions => {:language_id => 2}
  has_many :descriptions_en, :class_name => 'ProductDescription', :foreign_key => :products_id, :conditions => {:language_id => 3}
  
  has_many :ratings, :foreign_key => :products_id
  has_many :ratings_imdb, :class_name => 'Rating', :foreign_key => :imdb_id, :primary_key => :imdb_id
  has_many :reviews, :foreign_key => :imdb_id, :primary_key => :imdb_id
  has_many :trailers, :foreign_key => :products_id
  has_many :uninteresteds, :foreign_key => :products_id
  has_many :uninterested_customers, :through => :uninteresteds, :source => :customer, :uniq => true
  has_many :wishlist_items
  has_many :product_views
  has_many :streaming_products, :foreign_key => :imdb_id, :primary_key => :imdb_id, :conditions => {:available => 1, :season_id => 0}
  has_many :tokens, :foreign_key => :imdb_id, :primary_key => :imdb_id
  has_many :recommendations_products, :through => :recommendations, :source => :product
  has_many :highlight_products
  has_many :streaming_trailers, :foreign_key => :imdb_id, :primary_key => :imdb_id
  has_many :tokens_trailers, :foreign_key => :imdb_id, :primary_key => :imdb_id
  has_and_belongs_to_many :actors, :join_table => :products_to_actors, :foreign_key => :products_id, :association_foreign_key => :actors_id
  has_and_belongs_to_many :categories, :join_table => :products_to_categories, :foreign_key => :products_id, :association_foreign_key => :categories_id
  has_and_belongs_to_many :collections, :join_table => :products_to_themes, :foreign_key => :products_id, :association_foreign_key => :themes_id
  has_and_belongs_to_many :languages, :join_table => 'products_to_languages', :foreign_key => :products_id, :association_foreign_key => :products_languages_id, :conditions => {:languagenav_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_and_belongs_to_many :product_lists, :join_table => :listed_products, :order => 'listed_products.order asc'
  has_and_belongs_to_many :soundtracks, :join_table => :products_to_soundtracks, :foreign_key => :products_id, :association_foreign_key => :products_soundtracks_id
  has_and_belongs_to_many :seen_customers, :class_name => 'Customer', :join_table => :products_seen, :uniq => true
  has_and_belongs_to_many :subtitles, :join_table => 'products_to_undertitles', :foreign_key => :products_id, :association_foreign_key => :products_undertitles_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}

  named_scope :normal_available, :conditions => ['products_status != :status AND products_type = :kind', {:status => '-1', :kind => DVDPost.product_kinds[:normal]}]
  named_scope :adult_available, :conditions => ['products_status != :status AND products_type = :kind', {:status => '-1', :kind => DVDPost.product_kinds[:adult]}]
  named_scope :both_available, :conditions => ['products_status != :status', {:status => '-1'}]
  named_scope :available_in_dvd, :conditions => ['products_availability != :status', {:status => '2'}]
  named_scope :by_imdb_ids, lambda {|imdb| {:conditions => ["imdb_id in (#{imdb})"]}}
  named_scope :by_products_ids, lambda {|product_id| {:conditions => ["products_id in (#{product_id})"]}}
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :rating_count, :conditions => 'rating_count = 0'

  named_scope :ordered, :order => 'products_id desc'
  named_scope :ordered_media, :order => 'products_media desc'
  named_scope :group_by_imdb, :group => 'imdb_id'
  named_scope :group_by_serie, :group => 'products_series_id'
  named_scope :ordered_by_field, lambda {|products_id| {:order => "FIELD(products_id, #{products_id})"}}
  
  define_index do
    indexes products_media
    indexes products_type
    indexes actors.actors_name,                 :as => :actors_name
    indexes director.directors_name,            :as => :director_name
    indexes studio.studio_name,                 :as => :studio_name
    #indexes descriptions.products_description,  :as => :descriptions_text
    indexes descriptions.products_name,         :as => :descriptions_title
  
    has products_availability,      :as => :availability
    has products_countries_id,      :as => :country_id
    has products_date_available,    :as => :available_at
    has products_date_added,        :as => :created_at
    has products_dvdpostchoice,     :as => :dvdpost_choice
    has products_id,                :as => :id
    has products_next,              :as => :next
    has "CAST(vod_next AS SIGNED)", :type => :integer, :as => :vod_next
    has "CAST(vod_next_lux AS SIGNED)", :type => :integer, :as => :vod_next_lux
    has "CAST(vod_next_nl AS SIGNED)", :type => :integer, :as => :vod_next_nl
    has "if(products_next = 1,1,if(vod_next=1,1,0))", :type => :integer, :as => :all_next
    
    has products_public,            :as => :audience
    has products_year,              :as => :year
    has products_language_fr,       :as => :french
    has products_undertitle_nl,     :as => :dutch
    has products_rating,            :as => :dvdpost_rating
    has imdb_id
    has in_cinema_now
    has actors(:actors_id),         :as => :actors_id
    has categories(:categories_id), :as => :category_id
    has collections(:themes_id),    :as => :collection_id
    has director(:directors_id),    :as => :director_id
    has studio(:studio_id),         :as => :studio_id
    has languages(:languages_id),   :as => :language_ids
    has product_lists(:id),         :as => :products_list_ids
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST" and language_id = 1 and product_id = products.products_id limit 1)', :as => :highlight_best_fr, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST" and language_id = 2 and product_id = products.products_id limit 1)', :as => :highlight_best_nl, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST" and language_id = 3 and product_id = products.products_id limit 1)', :as => :highlight_best_en, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_BE" and language_id = 1 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_be_fr, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_BE" and language_id = 2 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_be_nl, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_BE" and language_id = 3 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_be_en, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_LU" and language_id = 1 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_lu_fr, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_LU" and language_id = 2 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_lu_nl, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_LU" and language_id = 3 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_lu_en, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_NL" and language_id = 1 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_nl_fr, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_NL" and language_id = 2 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_nl_nl, :type => :integer
    has '(select ifnull(rank,0) rank from `highlight_products` where day=0 and kind="BEST_VOD_NL" and language_id = 3 and product_id = products.products_id limit 1)', :as => :highlight_best_vod_nl_en, :type => :integer
    has "CAST(listed_products.order AS SIGNED)", :type => :integer, :as => :special_order
    has subtitles(:undertitles_id), :as => :subtitle_ids
    has 'cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1))', :type => :float, :as => :rating
    has streaming_products(:imdb_id), :as => :streaming_imdb_id
    has streaming_products(:is_ppv), :as => :is_ppv
    has streaming_products(:ppv_price), :as => :ppv_price, :type => :float
    
    has "min(streaming_products.id)", :type => :integer, :as => :streaming_id
    has "concat(GROUP_CONCAT(DISTINCT IFNULL(`products_languages`.`languages_id`, '0') SEPARATOR ','),',', GROUP_CONCAT(DISTINCT IFNULL(`products_undertitles`.`undertitles_id`, '0') SEPARATOR ','))", :type => :multi, :as => :speaker
    indexes "(select 
    group_concat(distinct `country` SEPARATOR ',') from streaming_products where imdb_id = products.imdb_id and status = 'online_test_ok' and available = 1 and ((date(now())  >= date(available_backcatalogue_from) and date(now()) <= date(date_add(available_backcatalogue_from, interval 3 month)))or(date(now())  >= date(available_from) and date(now()) <= date(date_add(available_from, interval 3 month)))))", :type => :multi, :as => :new_vod
    #to do
    has "(select (ifnull(replace(available_from,'-',''),replace(available_backcatalogue_from, '-',''))) date_order from streaming_products where imdb_id = products.imdb_id and status = 'online_test_ok' and available = 1 and ((date(now())  >= date(available_backcatalogue_from) and date(now()) <= date(date_add(available_backcatalogue_from, interval 3 month)))or(date(now())  >= date(available_from) and date(now()) <= date(date_add(available_from, interval 3 month)))) limit 1)", :type => :integer, :as => :available_order
    has "(select studio_id from streaming_products where imdb_id = products.imdb_id and status = 'online_test_ok' and available = 1 order by expire_backcatalogue_at asc limit 1)", :type => :integer, :as => :streaming_studio_id
    has 'cast((SELECT count(*) FROM `wishlist_assigned` wa WHERE wa.products_id = products.products_id and date_assigned > date_sub(now(), INTERVAL 1 MONTH) group by wa.products_id) AS SIGNED)', :type => :integer, :as => :most_viewed
    has 'cast((SELECT count(*) FROM `wishlist_assigned` wa WHERE wa.products_id = products.products_id and date_assigned > date_sub(now(), INTERVAL 1 YEAR) group by wa.products_id) AS SIGNED)', :type => :integer, :as => :most_viewed_last_year
  
    has "(select products_name AS products_name_ord from products_description pd where  language_id = 1 and pd.products_id = products.products_id)", :type => :string, :as => :descriptions_title_fr, :sortable => true
    has "(select products_name AS products_name_ord from products_description pd where  language_id = 2 and pd.products_id = products.products_id)", :type => :string, :as => :descriptions_title_nl, :sortable => true
    has "(select products_name AS products_name_ord from products_description pd where  language_id = 3 and pd.products_id = products.products_id)", :type => :string, :as => :descriptions_title_en, :sortable => true

    has "(select case 
            when (products_media = 'DVD' and streaming_products.imdb_id is not null) or (products_media = 'DVD' and vod_next = 1) then 2
            when (products_media = 'VOD' and streaming_products.imdb_id is not null) or (products_media = 'VOD' and vod_next = 1) then 5
            when products_media = 'DVD' then 1 
            when (products_media = 'blueray' and streaming_products.imdb_id is not null) or (products_media = 'blueray' and vod_next = 1) then 4 
            when products_media = 'blueray' then 3
            when products_media = 'bluray3d' then 6
            when products_media = 'bluray3d2d' then 7
            else 8 end from products p 
            left join streaming_products on streaming_products.imdb_id = p.imdb_id and country ='BE' and ( streaming_products.status = 'online_test_ok' and (streaming_products.expire_backcatalogue_at >= date(now()) or streaming_products.expire_backcatalogue_at is null) and available = 1)
            where  p.products_id =  products.products_id limit 1)", :type  => :integer, :as => :special_media_be
    has "(select case 
            when (products_media = 'DVD' and streaming_products.imdb_id is not null ) or (products_media = 'DVD' and vod_next_lux = 1) then 2
            when (products_media = 'VOD' and streaming_products.imdb_id is not null ) or (products_media = 'VOD' and vod_next_lux = 1) then 5
            when products_media = 'DVD' then 1 
            when (products_media = 'blueray' and streaming_products.imdb_id is not null ) or (products_media = 'blueray' and vod_next_lux = 1) then 4 
            when products_media = 'blueray' then 3
            when products_media = 'bluray3d' then 6
            when products_media = 'bluray3d2d' then 7
            else 8 end 
            from products p
            left join streaming_products on streaming_products.imdb_id = p.imdb_id and country ='LU' and ( streaming_products.status = 'online_test_ok' and (streaming_products.expire_backcatalogue_at >= date(now()) or streaming_products.expire_backcatalogue_at is null) and available = 1)
            where p.products_id =  products.products_id limit 1)", :type  => :integer, :as => :special_media_lu
    has "(select case 
            when (products_media = 'DVD' and streaming_products.imdb_id is not null ) or (products_media = 'DVD' and vod_next_nl = 1) then 2
            when (products_media = 'VOD' and streaming_products.imdb_id is not null ) or (products_media = 'VOD' and vod_next_nl = 1) then 5
            when products_media = 'DVD' then 1 
            when (products_media = 'blueray' and streaming_products.imdb_id is not null ) or (products_media = 'blueray' and vod_next_nl = 1) then 4 
            when products_media = 'blueray' then 3
            when products_media = 'bluray3d' then 6
            when products_media = 'bluray3d2d' then 7
            else 8 end 
            from products p
            left join streaming_products on streaming_products.imdb_id = p.imdb_id and country ='NL' and ( streaming_products.status = 'online_test_ok' and (streaming_products.expire_backcatalogue_at >= date(now()) or streaming_products.expire_backcatalogue_at is null) and available = 1)
            where p.products_id =  products.products_id limit 1)", :type  => :integer, :as => :special_media_nl
    
    indexes "(select group_concat(distinct country) from streaming_products where imdb_id = products.imdb_id and streaming_products.status = 'online_test_ok' and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1 limit 1)", :type => :multi, :as => :streaming_available
    has "(select count(*) c from tokens where tokens.imdb_id = products.imdb_id and (datediff(now(),created_at) < 8))", :type => :integer, :as => :count_tokens
    has "(select count(*) c from tokens where tokens.imdb_id = products.imdb_id and (datediff(now(),created_at) < 31))", :type => :integer, :as => :count_tokens_month
    has "case
    when products_date_available > DATE_SUB(now(), INTERVAL 8 MONTH) and products_date_available < DATE_SUB(now(), INTERVAL 3 MONTH) and products_series_id = 0 and cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) >= 3 and products_quantity > 0 then 1
    when products_date_available < DATE_SUB(now(), INTERVAL 8 MONTH) and products_series_id = 0 and cast((cast((rating_users/rating_count)*2 AS SIGNED)/2) as decimal(2,1)) >= 4 and products_quantity > 2 then 1
    else 0 end", :type => :integer, :as => :popular
    has 'concat(if(products_quantity>0 or products_media = "vod" or (  select count(*) > 0 from products p
          join streaming_products on streaming_products.imdb_id = p.imdb_id
          where  ((country="BE" and streaming_products.status = "online_test_ok" and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1) or p.vod_next=1 or streaming_products.imdb_id is null)  and p.products_id =  products.products_id),1,0),date_format(products_date_available,"%Y%m%d"))', :type => :integer, :as => :default_order_be
    has 'concat(if(products_quantity>0  or (  select count(*) > 0 from products p
          join streaming_products on streaming_products.imdb_id = p.imdb_id
          where  ((country="LU" and streaming_products.status = "online_test_ok" and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1) or p.vod_next_lux=1 or streaming_products.imdb_id is null)  and p.products_id =  products.products_id),1,0),date_format(products_date_available,"%Y%m%d"))', :type => :integer, :as => :default_order_lu

    has 'concat(if(products_quantity>0 or (  select count(*) > 0 from products p
          join streaming_products on streaming_products.imdb_id = p.imdb_id
          where  ((country="NL" and streaming_products.status = "online_test_ok" and ((streaming_products.available_from <= date(now()) and streaming_products.expire_at >= date(now())) or (streaming_products.available_backcatalogue_from <= date(now()) and streaming_products.expire_backcatalogue_at >= date(now()))) and available = 1) or p.vod_next_nl=1 or streaming_products.imdb_id is null)  and p.products_id =  products.products_id),1,0),date_format(products_date_available,"%Y%m%d"))', :type => :integer, :as => :default_order_nl

    has "case 
    when  products_status = -1 then 99
    else products_status end", :type => :integer, :as => :status
    has products_quantity,          :type => :integer, :as => :in_stock
    has products_series_id,          :type => :integer, :as => :series_id
    set_property :enable_star => true
    set_property :min_prefix_len => 3
    set_property :charset_type => 'sbcs'
    set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
    set_property :ignore_chars => "U+AD"
    set_property :field_weights => {:descriptions_title => 10, :actors_name => 5, :director_name => 5, :studio_name => 4}
  end

  # There are a lot of commented lines of code in here which are just used for development
  # Once all scopes are transformed to Thinking Sphinx scopes, it will be cleaned up.
  sphinx_scope(:by_products_id)           {|products_id|      {:with =>       {:id => products_id}}}
  sphinx_scope(:exclude_products_id)      {|products_id|      {:without =>    {:id => products_id}}}
  sphinx_scope(:by_actor)                 {|actor|            {:with =>       {:actors_id => actor.to_param}}}
  sphinx_scope(:by_audience)              {|min, max|         {:with =>       {:audience => Public.legacy_age_ids(min, max)}}}
  sphinx_scope(:by_category)              {|category|         {:with =>       {:category_id => category.to_param}}}
  sphinx_scope(:by_collection)            {|collection|       {:with =>       {:collection_id => collection.to_param}}}
  sphinx_scope(:hetero)                   {{:without =>       {:category_id => [76, 72]}}}
  sphinx_scope(:gay)                      {{:with =>          {:category_id => [76, 72]}}}
  sphinx_scope(:by_country)               {|country|          {:with =>       {:country_id => country.to_param}}}
  sphinx_scope(:by_director)              {|director|         {:with =>       {:director_id => director.to_param}}}
  sphinx_scope(:by_studio)                {|studio|           {:with =>       {:studio_id => studio.to_param}}}
  sphinx_scope(:by_streaming_studio)      {|studio|           {:with =>       {:streaming_studio_id => studio.to_param}}}
  sphinx_scope(:by_imdb_id)               {|imdb_id|          {:with =>       {:imdb_id => imdb_id}}}
  sphinx_scope(:by_language)              {|language|         {:order =>      language.to_s == 'fr' ? :french : :dutch, :sort_mode => :desc}}
  sphinx_scope(:by_kind)                  {|kind|             {:conditions => {:products_type => DVDPost.product_kinds[kind]}}}
  sphinx_scope(:by_media)                 {|media|            {:conditions => {:products_media => media}}}
  sphinx_scope(:by_special_media_be)      {|media|            {:with =>       {:special_media_be => media}}}
  sphinx_scope(:by_special_media_lu)      {|media|            {:with =>       {:special_media_lu => media}}}
  sphinx_scope(:by_special_media_nl)      {|media|            {:with =>       {:special_media_nl => media}}}
  sphinx_scope(:remove_wrong_be)          {|media|            {:without =>    {:special_media_be => media}}}
  sphinx_scope(:remove_wrong_lu)          {|media|            {:without =>    {:special_media_lu => media}}}
  sphinx_scope(:remove_wrong_nl)          {|media|            {:without =>    {:special_media_nl => media}}}
  sphinx_scope(:by_period)                {|min, max|         {:with =>       {:year => min..max}}}
  sphinx_scope(:by_products_list)         {|product_list|     {:with =>       {:products_list_ids => product_list.to_param}}}
  sphinx_scope(:by_ratings)               {|min, max|         {:with =>       {:rating => min..max}}}
  sphinx_scope(:by_recommended_ids)       {|recommended_ids|  {:with =>       {:id => recommended_ids}}}
  sphinx_scope(:with_languages)           {|language_ids|     {:with =>       {:language_ids => language_ids}}}
  sphinx_scope(:with_subtitles)           {|subtitle_ids|     {:with =>       {:subtitle_ids => subtitle_ids}}}
  sphinx_scope(:with_speaker)             {|speaker_ids|      {:with =>       {:speaker => speaker_ids}}}
  sphinx_scope(:available)                {{:without =>       {:status => [99]}}}
  sphinx_scope(:dvdpost_choice)           {{:with =>          {:dvdpost_choice => 1}}}
  sphinx_scope(:recent)                   {{:without =>       {:availability => 0}, :with => {:available_at => 2.months.ago..Time.now.end_of_day, :next => 0}}}
  sphinx_scope(:new_vod)                  {|country|          {:conditions =>    {:new_vod => country}}}
  sphinx_scope(:cinema)                   {{:with =>          {:in_cinema_now => 1, :next => 1}}}
  sphinx_scope(:soon)                     {{:with =>          {:in_cinema_now => 0, :next => 1}}}
  sphinx_scope(:dvd_soon)                 {{:with =>          {:in_cinema_now => 0, :next => 1}}}
  sphinx_scope(:vod_soon)                 {{:with =>          {:vod_next => 1}}}
  sphinx_scope(:not_soon)                 {{:with =>          {:vod_next => 0}}}
  sphinx_scope(:vod_soon_lux)             {{:with =>          {:vod_next_lux => 1}}}
  sphinx_scope(:not_soon_lux)             {{:with =>          {:vod_next_lux => 0}}}
  sphinx_scope(:vod_soon_nl)              {{:with =>          {:vod_next_nl => 1}}}
  sphinx_scope(:not_soon_nl)              {{:with =>          {:vod_next_nl => 0}}}
  sphinx_scope(:streaming)                {|country|          {:without =>       {:streaming_imdb_id => 0}, :country => {:streaming_available => country}}}
  sphinx_scope(:random)                   {{:order =>         '@random'}}
  sphinx_scope(:popular_new)              {{:with =>          {:popular => 1}}}
  sphinx_scope(:highlight_best_fr)        {{:with =>          {:highlight_best_fr => 1..100}}}
  sphinx_scope(:highlight_best_nl)        {{:with =>          {:highlight_best_nl => 1..100}}}
  sphinx_scope(:highlight_best_en)        {{:with =>          {:highlight_best_en => 1..100}}}
  sphinx_scope(:highlight_best_vod_be_fr) {{:with =>          {:highlight_best_vod_be_fr => 1..100}}}
  sphinx_scope(:highlight_best_vod_be_nl) {{:with =>          {:highlight_best_vod_be_nl => 1..100}}}
  sphinx_scope(:highlight_best_vod_be_en) {{:with =>          {:highlight_best_vod_be_en => 1..100}}}
  sphinx_scope(:highlight_best_vod_lu_fr) {{:with =>          {:highlight_best_vod_lu_fr => 1..100}}}
  sphinx_scope(:highlight_best_vod_lu_nl) {{:with =>          {:highlight_best_vod_lu_nl => 1..100}}}
  sphinx_scope(:highlight_best_vod_lu_en) {{:with =>          {:highlight_best_vod_lu_en => 1..100}}}
  sphinx_scope(:highlight_best_vod_nl_fr) {{:with =>          {:highlight_best_vod_nl_fr => 1..100}}}
  sphinx_scope(:highlight_best_vod_nl_nl) {{:with =>          {:highlight_best_vod_nl_nl => 1..100}}}
  sphinx_scope(:highlight_best_vod_nl_en) {{:with =>          {:highlight_best_vod_nl_en => 1..100}}}
  sphinx_scope(:popular)                  {{:with =>          {:available_at => 8.months.ago..2.months.ago, :rating => 3.0..5.0, :series_id => 0, :in_stock => 3..1000}}}
  sphinx_scope(:not_recent)               {{:with =>          {:next => 0}}}
  sphinx_scope(:by_serie)                 {|serie_id|         {:with => {:series_id => serie_id}}}
  sphinx_scope(:ppv)                      {{:with =>          {:is_ppv => 1}}}
  sphinx_scope(:by_new)                   {{:with =>          {:year => 2.years.ago.year..Date.today.year, :next => 0, :available_at => 3.months.ago..Time.now.end_of_day}}}
  sphinx_scope(:order)                    {|order, sort_mode| {:order => order, :sort_mode => sort_mode}}
  sphinx_scope(:group)                    {|group,sort|       {:group_by => group, :group_function => :attr, :group_clause   => sort}}
                                          
  sphinx_scope(:limit)                    {|limit|            {:limit => limit}}

  def self.list_sort
     sort = OrderedHash.new
     sort.push(:normal, 'normal')
     sort.push(:alpha_az, 'alpha_az')
     sort.push(:alpha_za, 'alpha_za')
     sort.push(:rating, 'rating')
     sort.push(:most_viewed, 'most_viewed')
     sort.push(:most_viewed_last_year, 'most_viewed_last_year')
     sort.push(:new, 'new')
     sort.push(:production_year, 'production_year')
     
     sort
  end
  
  
  def self.filter(filter, options={}, exact=nil)
    if options[:country_id] == 131
      country = 'LU'
      default = 'default_order_lu'
    elsif options[:country_id] == 161
      country = 'NL'
      default = 'default_order_nl'
    else
      country = 'BE'
      default = 'default_order_be'
    end
    if options[:exact]
      products = search_clean_exact(options[:search], {:page => options[:page], :per_page => options[:per_page], :limit => options[:limit]})
    else
      products = search_clean(options[:search], {:page => options[:page], :per_page => options[:per_page], :limit => options[:limit]})
    end
    products = products.exclude_products_id([exact.collect(&:products_id)]) if exact
    products = products.by_products_list(options[:list_id]) if options[:list_id] && !options[:list_id].blank?
    products = products.by_products_id(options[:products_id].split(',')) if options[:products_id] && !options[:products_id].blank?
    products = products.by_actor(options[:actor_id]) if options[:actor_id]
    products = products.by_category(options[:category_id]) if options[:category_id]
    products = products.by_collection(options[:collection_id]) if options[:collection_id]
    products = products.hetero if options[:hetero] && ((options[:category_id].to_i != 76 && options[:category_id].to_i != 72))
    products = products.by_director(options[:director_id]) if options[:director_id]
    products = products.by_imdb_id(options[:imdb_id]) if options[:imdb_id]
    products = products.ppv if options[:ppv]
    products = products.streaming(country) if options[:view_mode] == "streaming" || (options[:filter] == "vod" and options[:view_mode] != 'vod_soon')
    if options[:highlight_best]
      case options[:locale]
        when 'fr'
          products = products.highlight_best_fr
        when 'nl'
          products = products.highlight_best_nl
        when 'en'
          products = products.highlight_best_en
      end
    end
    if options[:highlight_best_vod]
      case options[:locale]
        when 'fr'
          products = 
          case options[:country_id]
            when 131
              products.highlight_best_vod_lu_fr
            when 161
              products.highlight_best_vod_nl_fr
            else
              products.highlight_best_vod_be_fr
          end
        when 'nl'
          case options[:country_id]
            when 131
              products.highlight_best_vod_lu_nl
            when 161
              products.highlight_best_vod_nl_nl
            else
              products.highlight_best_vod_be_nl
          end
        when 'en'
          case options[:country_id]
            when 131
              products.highlight_best_vod_lu_en
            when 161
              products.highlight_best_vod_nl_en
            else
              products.highlight_best_vod_be_en
          end
      end
    end
    if options[:studio_id]
      if options[:filter] == "vod" && options[:kind] == :normal
        products = products.by_streaming_studio(options[:studio_id]) 
      else
        products = products.by_studio(options[:studio_id]) 
      end
    end
    products = products.by_audience(filter.audience_min, filter.audience_max) if filter.audience? && options[:kind] == :normal && options[:no_filter].nil?
    products = products.by_country(filter.country_id) if filter.country_id? && options[:no_filter].nil?
    if options[:filter] && options[:no_filter].nil?
      if options[:filter] && options[:filter] == "vod"
        media_i = [2,4,5]
      elsif options[:filter] && options[:filter] == "dvd"
        media_i = [1,2]
      elsif options[:filter] && options[:filter] == "bluray"
        media_i = [3,4,7]
      elsif options[:filter] && options[:filter] == "bluray3d"
        media_i = [6,7]
      end
      if media_i
        products = Product.media_select(products, country, media_i)
      end
    end
    
    if filter.media? && options[:view_mode] != "streaming" && options[:filter] != "vod" && options[:no_filter].nil?
      
      medias = filter.media.dup
      media_i = Array.new
      if medias.include?(:dvd)
        if medias.include?(:bluray)
          if medias.include?(:streaming)
            media_i = [1,2,3,4,5,7]
          else
            media_i = [1,2,3,4,7]
          end
        elsif medias.include?(:streaming)
          media_i = [1,2,5]
        else
          media_i = [1,2]
        end
      elsif medias.include?(:bluray)
        if medias.include?(:streaming)
          media_i = [2,3,4,5,7]
        else
          media_i = [3,4,7]
        end
      elsif medias.include?(:streaming)
        media_i = [2,4,5,7]
      end
      if medias.include?(:bluray3d)
        media_i.push([6,7])
      end
      products = Product.media_select(products, country, media_i)
    end
    case country
      when 'BE'
        products = products.remove_wrong_be(8)
      when 'LU'
        products = products.remove_wrong_lu(8)
      when 'NL'
        products = products.remove_wrong_nl(8)
    end
    products = products.by_ratings(filter.rating_min.to_f, filter.rating_max.to_f) if filter.rating?
    products = products.by_period(filter.year_min, filter.year_max) if filter.year? && options[:no_filter].nil?
    if filter.audio? && options[:no_filter].nil?
      products = products.with_languages(filter.audio)
    else
      products = products.with_languages(options[:audio]) if options[:audio] 
    end
    if filter.subtitles? && options[:no_filter].nil?
      products = products.with_subtitles(filter.subtitles) 
    else
      products = products.with_subtitles(options[:subtitles]) if options[:subtitles] 
    end
    products = products.dvdpost_choice if filter.dvdpost_choice? && options[:no_filter].nil?
    if options[:not_soon]
      products = 
      case options[:country_id]
        when 131 
          products.not_soon_lux
        when 161
          products.not_soon_nl
        else
          products.not_soon
      end
    end
    if options[:sort] == 'production_year_vod'
      products = products.streaming(country).by_period(2.years.ago.year, Date.today.year).new_vod(country)
    elsif options[:sort] == 'production_year_all'
      products = products.by_new
    else
      products = products.by_period(filter.year_min, filter.year_max) if filter.year?
    end
    if options[:view_mode]
      products = case options[:view_mode].to_sym
      when :recent
        products.recent
      when :vod_recent
        products.new_vod(country)
      when :soon
        products.soon
      when :vod_soon
        case options[:country_id]
          when 131
            products.vod_soon_lux
          when 161
            products.vod_soon_nl
          else
            products.vod_soon
        end
      when :cinema
        products.cinema
      when :streaming
        products = Product.media_select(products, country, [2,4,5])
      when :popular_streaming
          products.streaming(country).limit(10)
      when :recommended
        recom = products.by_recommended_ids(filter.recommended_ids).with_speaker(options[:language]).limit(50)
        recom
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

    if options[:list_id] && !options[:list_id].blank?
      sort = sort_by("special_order asc", options)
    elsif options[:highlight_best] && !options[:highlight_best].blank?
      sort = sort_by("highlight_best_#{options[:locale]} asc", options)
    elsif options[:highlight_best_vod]
      sort = sort_by("highlight_best_vod_#{options[:country_id] == 131 ? 'lu' : 'be'}_#{options[:locale]} asc", options)
    elsif options[:search] && !options[:search].blank?
      sort = sort_by("#{default} desc, in_stock DESC", options)
    elsif options[:view_mode] && options[:view_mode].to_sym == :streaming
      sort = sort_by("streaming_id desc", options)
    elsif options[:view_mode] && options[:view_mode].to_sym == :vod_recent
      sort = sort_by("available_order desc", options)
    elsif options[:view_mode] && options[:view_mode].to_sym == :vod_soon
      sort = sort_by("available_at asc", options)
    elsif options[:view_mode] && options[:view_mode].to_sym == :popular_streaming
      sort = sort_by("count_tokens desc, streaming_id desc", options)
    elsif options[:view_mode] && options[:view_mode].to_sym == :popular
      sort = sort_by("available_at DESC, rating desc", options)
    elsif options[:view_mode] && (options[:view_mode].to_sym == :recent || options[:view_mode].to_sym == :soon)
      sort = sort_by("available_at desc, imdb_id desc", options)
    elsif options[:view_mode] && options[:view_mode].to_sym == :cinema
      sort = sort_by("created_at desc", options)
    elsif options[:filter] && options[:filter].to_sym == :vod
      sort = sort_by("streaming_id desc", options)
    else
      sort = sort_by("#{default} desc, in_stock DESC", options)
    end
    if sort !=""
      if (options[:group]) || (options[:view_mode] && (options[:view_mode].to_sym == :streaming || options[:view_mode].to_sym == :popular_streaming)) || (options[:filter] && options[:filter].to_sym == :vod)
        products = products.group('imdb_id', sort)
      else
        products = products.order(sort, :extended)
      end
    else
      if options[:filter] && options[:filter].to_sym == :vod
         products = products.group('imdb_id', "streaming_id desc")
      end
    end
    #if options[:limit]
  #    products = products.limit(options[:limit])
    #end
    products
    # products = products.sphinx_order('listed_products.order asc', :asc) if params[:top_id] && !params[:top_id].empty?
  end

  def hd?(country)
    country_short = case country
      when 131
        'LU'
      when 161
        'NL'
      else
        'BE'
      end
    self.streaming_products.available.country(country_short).hd.size > 0
  end

  def recommendations(kind, customer)
    begin
      # external service call can't be allowed to crash the app
      data  = DVDPost.product_linked_recommendations(self, kind, I18n.locale, customer ? customer.to_param : nil )
      recommendation_ids = data[:dvd_id]
      response_id = data[:response_id]
      url = data[:url]
    rescue => e
      logger.error("Failed to retrieve recommendations: #{e.message}")
    end
    if recommendation_ids && !recommendation_ids.empty?
      if kind == :normal
        {:products => Product.available.by_products_id(recommendation_ids), :response_id => response_id}
      else
        if categories.find_by_categories_id([76,72])
          {:products => Product.available.gay.by_products_id(recommendation_ids), :response_id => response_id}
        else
          {:products => Product.available.hetero.by_products_id(recommendation_ids), :response_id => response_id}
        end
      end
    end
  end

  def recommendations_new(kind, customer_id, type)
    begin
      # external service call can't be allowed to crash the app
      recommendation_ids = DVDPost.product_linked_recommendations_new(self, kind, customer_id, type)
    rescue => e
      logger.error("Failed to retrieve recommendations: #{e.message}")
    end
    if recommendation_ids && !recommendation_ids.empty?
      if kind == :normal
        Product.both_available.ordered_by_field(recommendation_ids.join(',')).group_by_imdb.find_all_by_products_id(recommendation_ids)
        
        #Product.search(:max_matches => 200, :per_page => 100,:group_by => 'imdb_id', :group_function => :attr).available.by_products_id(recommendation_ids)
      else
        if categories.find_by_categories_id([76,72])
          Product.available.gay.by_products_id(recommendation_ids)
        else
          Product.available.hetero.by_products_id(recommendation_ids)
        end
      end
    end    
  end

  def description
    case I18n.locale
      when :nl
        descriptions_nl.first
      when :en
        descriptions_en.first
      else
        descriptions_fr.first
      end
        
  end

  def to_param
      public_name
  end

  def public_name
    if ENV['HOST_OK'] == "1"
      desc = descriptions.by_language(I18n.locale).first
      desc && !desc.cached_name.nil? ? "#{id}-#{desc.cached_name}" : id
    else
      id
    end
  end

  def title
    if desc = description
      desc.title
    else
      products_title
    end
  end

  def trailer
    localized_trailers = trailers.by_language(I18n.locale.to_s)
    localized_trailers.mobile if ENV['HOST_OK'] == "1"
    localized_trailers ? localized_trailers.first : nil
  end

  def image
    if desc = description
      if products_type == DVDPost.product_kinds[:adult]
        File.join(DVDPost.imagesx_path, desc.image)  if !desc.image.blank?
      else
        File.join(DVDPost.images_path, desc.image) if !desc.image.blank?
      end
    end
  end

  def image_detail
    File.join(DVDPost.images_path, 'products', "#{id}.jpg")
  end

  def description_data(full = false)
    if desc = description
      title = desc.title
      if products_type == DVDPost.product_kinds[:adult]
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
  
  def preview_image(id, kind)
    path = kind == :adult ? DVDPost.imagesx_preview_path : DVDPost.images_preview_path
    File.join(path,'small', "#{imdb_id}_#{id}.jpg")
  end

  def trailer_image(kind)
    path = kind == :adult ? DVDPost.imagesx_trailer_path : DVDPost.images_trailer_path
    File.join(path, "#{id}.jpg")
  end

  def banner_image(kind)
    path = kind == :adult ? DVDPost.imagesx_banner_path : DVDPost.images_banner_path
    File.join(path, "#{id}.jpg")
  end

  def rating(customer = nil)
    if customer && customer.has_rated?(self)
      if imdb_id > 0 && rating = ratings_imdb.by_customer(customer).first
        {:rating => rating.value.to_i * 2, :customer => true}
      else
        {:rating => ratings.by_customer(customer).first.value.to_i * 2, :customer => true}
      end
    else
      rating = rating_count == 0 ? 0 : ((rating_users.to_f / rating_count) * 2).round
      {:rating => rating, :customer => false}
    end
  end

  def rate!(value)
    if imdb_id > 0
      Product.find_all_by_imdb_id(imdb_id).each {|product| 
        product.update_attributes(:rating_count => product.rating_count+1, :rating_users => product.rating_users + value)
      }
    else
      update_attributes({:rating_count => (rating_count + 1), :rating_users => (rating_users + value)})
    end
  end

  def is_new?
    created_at < Time.now && available_at && available_at > 3.months.ago && products_next == 0 && year >= 2.year.ago.strftime('%Y').to_i
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

  def bluray3d?
    media == DVDPost.product_types[:bluray3d]
  end

  def bluray3d2d?
    media == DVDPost.product_types[:bluray3d2d]
  end

  def vod?
    media == DVDPost.product_types[:vod]
  end

  def series?
    products_series_id != 0
  end

  def available_to_sale?
    quantity_to_sale > 0 && ProductList.shop.status.by_language(DVDPost.product_languages[I18n.locale]).first && ProductList.shop.status.by_language(DVDPost.product_languages[I18n.locale]).first.products.include?(self)
  end

  def in_streaming_or_soon?(kind =  :normal, country_id = 21)
    
    streaming_next = case country_id
      when 131
        vod_next_lux
      when 161
        vod_next_nl
      else
        vod_next
    end
    streaming?(kind, country_id) || streaming_next
  end

  def streaming?(kind =  :normal, country_id = 21)
    sql = streaming_products
    unless Rails.env == "pre_production"
      country = case country_id
        when 131
          'LU'
        when 161
          'NL'
        else
          'BE'
        end
        sql = sql.available.country(country)
    end
    sql = sql.first
    sql
  end

  def in_streaming?(kind =  :normal, country_id = 21)
    if streaming?(kind =  :normal, country_id = 21).nil?
      false
    else
      true
    end
  end

  def good_language?(language)
    languages.find_by_languages_id(language) || subtitles.find_by_undertitles_id(language)
  end

  def views_increment(desc)
    # Dirty raw sql.
    # This could be fixed with composite_primary_keys but version 2.3.5.1 breaks all other associations.
    if desc
      connection.execute("UPDATE products_description SET products_viewed = #{desc.viewed + 1} WHERE (products_id = #{id}) AND (language_id = #{DVDPost.product_languages[I18n.locale]})")
    end
    day = product_views.daily.first
    if !day.nil?
      day.update_attributes(:number => (day.number + 1))
    else
      ProductView.create(:product_id => to_param,
                          :number     => 1)
    end
    desc ? desc.viewed : 0
  end

  def media_alternative(media)
    if imdb_id > 0
      if I18n.locale == :nl
        self.class.available.by_kind(:normal).by_imdb_id(imdb_id).by_media([media]).with_subtitles(DVDPost.product_languages[I18n.locale]).limit(1).first
      else
        self.class.available.by_kind(:normal).by_imdb_id(imdb_id).by_media([media]).with_languages(DVDPost.product_languages[I18n.locale]).limit(1).first
      end
    end
  end
  
  def media_alternative_all(media)
    if imdb_id > 0
      self.class.available.by_kind(:normal).by_imdb_id(imdb_id).by_media([media]).limit(1).first
    end
  end

  def self.sort_by(default, options={})
    if options[:sort]
      type =
      if options[:sort] == 'alpha_az'
        "descriptions_title_#{I18n.locale} asc"
      elsif options[:sort] == 'alpha_za'
        "descriptions_title_#{I18n.locale} desc"
      elsif options[:sort] == 'rating'
        "rating desc, in_stock DESC"
      elsif options[:sort] == 'production_year'
        "year desc, in_stock DESC"
      elsif options[:sort] == 'production_year_vod'
        "year desc, available_order desc"
      elsif options[:sort] == 'production_year_all'
        "year desc, available_at desc"
      elsif options[:sort] == 'token'
        "count_tokens desc, streaming_id desc"
      elsif options[:sort] == 'token_month'
        "count_tokens_month desc, streaming_id desc"
      elsif options[:sort] == 'most_viewed'
        "most_viewed desc"
      elsif options[:sort] == 'most_viewed_last_year'
        "most_viewed_last_year desc"
      elsif options[:sort] == 'new'
        "available_at DESC, rating desc"
      elsif options[:sort] == 'recent1'
        "#{default} desc"
      elsif options[:sort] == 'recent2'
        "in_stock desc"
      elsif options[:sort] == 'recent3'
        "#{default} desc, in_stock desc"
      else
        default
      end
    else
      default
    end
  end

  def self.search_clean(query_string, options={})
    qs = []
    if query_string
      query_string = query_string.gsub(' et ',' ')
      qs = query_string.split.collect do |word|
        "*#{replace_specials(word)}*".gsub(/[-_]/, ' ').gsub(/[$!^]/, '')
      end
    end
    query_string = qs.join(' ')
    query_string = "@descriptions_title #{query_string}" if !query_string.empty?
    page = options[:page] || 1
    limit = options[:limit] ? options[:limit].to_s : "100_000"
    per_page = options[:per_page] || self.per_page
    self.search(query_string, :max_matches => limit, :per_page => per_page, :page => page)
  end

  def self.search_clean_exact(query_string, options={})
    qs = []
    if query_string
      qs = query_string.split.collect do |word|
        replace_specials(word).gsub(/[-_]/, ' ').gsub(/[$!^]/, '').gsub(' et ',' ')
      end
    end
    query_string = qs.join(' ')
    query_string = "@descriptions_title ^#{query_string}$"
    page = 1
    limit = options[:limit] ? options[:limit].to_s : "100_000"
    per_page = 20
    self.search(query_string, :max_matches => limit, :per_page => per_page, :page => page)
  end

  def self.replace_specials(str)
    str.removeaccents
  end

  def self.notify_hoptoad(ghost)
    begin
      Airbrake.notify(:error_message => "Ghost record found: #{ghost.inspect}", :backtrace => $@, :environment_name => ENV['RAILS_ENV'])
    rescue => e
      logger.error("Exception raised wihile notifying ghost record found: #{ghost.inspect}")
      logger.error(e.backtrace)
    end
  end

  def self.get_jacket_mode(params)
    if params[:list_id] && !params[:list_id].blank?
      style = ProductList.find(params[:list_id]).style
      if style == 'STREAMING'
        jacket_mode = :streaming
      end
    end
    if (params[:view_mode] && (params[:view_mode].to_sym == :streaming || params[:view_mode].to_sym == :popular_streaming )) || (params[:filter] && params[:filter].to_sym == :vod)
      jacket_mode = :streaming
    end
    if jacket_mode.nil?
      jacket_mode = :normal
    end
    jacket_mode
  end

  def self.get_soon(locale)
    case locale
      when :fr
        Product.by_kind(:normal).available.soon.with_languages(1).random.limit(3)
      when :nl
        Product.by_kind(:normal).available.soon.with_subtitles(2).random.limit(3)
      when :en
        Product.by_kind(:normal).available.soon.random.limit(3)
      end
  end

  def self.get_recent(locale, kind, limit, sexuality)
    if kind == :adult
      if sexuality == 1
        Product.by_kind(kind).available.recent.random.limit(limit)
      else
        Product.by_kind(kind).available.recent.hetero.random.limit(limit)
      end
    else
      case locale
        when :fr
          Product.by_kind(kind).available.recent.with_languages(1).random.limit(limit)
        when :nl
          Product.by_kind(kind).available.recent.with_subtitles(2).random.limit(limit)
        when :en
          Product.by_kind(kind).available.recent.random.limit(limit)
        end
    end
  end

  def self.get_top_view(kind, limit, sexuality,country_id)
    products = Product.by_kind(kind)
    country = case country 
    when 131
      'LU'
    when 161
      'NL'
    else
      'BE'
    end
    products = Product.media_select(products, country, [2,4,5])
    products = products.available
    products = products.hetero if sexuality != 1
    products = products.limit(limit).order('count_tokens desc', :extended)
  end

  def self.media_select(products, country, media)
    case country
      when 'BE'
        products.by_special_media_be(media)
      when 'LU'
        products.by_special_media_lu(media)
      when 'NL'
        products.by_special_media_nl(media)
    end
  end

  def adult?
    products_type == DVDPost.product_kinds[:adult]
  end

  def title_test
    if imdb_id >0
      title_db = products_title.upcase
      puts title_db
      title_imdb =  open "http://www.imdb.com/title/tt#{imdb_id}/" do |data|  p=/(.*)(\(.*\))/;       title = Hpricot(data).search('//h1').text.gsub(p, "\\1"); title.gsub(/\n/,'')  end
      title_imdb = CGI.unescapeHTML(title_imdb).upcase
      if title_db == title_imdb
        puts 'ok'
      else
        puts " not ok #{title_db} <==> #{title_imdb}"
      end
    end
    return ''
  end

  def self.title_test
    
    Product.normal_available.each do |product|
      if product.imdb_id >0
        
        title_db = product.products_title.upcase
        #puts title_db
        title_imdb =  open "http://www.imdb.com/title/tt#{product.imdb_id}/" do |data|  p=/(.*)(\(.*\))/;       title = Hpricot(data).search('//h1').text.gsub(p, "\\1"); title.gsub(/\n/,'')  end
        title_imdb = CGI.unescapeHTML(title_imdb).upcase
        if title_db == title_imdb
          #puts 'ok'
        else
          puts " not ok #{title_db} <==> #{title_imdb}"
        end
      end
    end
    return ''
  end

  def self.rating_first
    Product.both_available.rating_count.update_all("rating_count=1 , `rating_users`= products_rating")
  end

  def trailer?
    trailer || ((Rails.env == "production" ? streaming_trailers.available.count > 0 : streaming_trailers.available_beta.count > 0) && tokens_trailers.available.first )
  end
  
  def trailer_streaming?
    ((Rails.env == "production" ? streaming_trailers.available.count > 0 : streaming_trailers.available_beta.count > 0) && tokens_trailers.available.first )
  end
  
  def self.country_short_name(country_id)
    case country_id
      when 131
        'LU'
      when 161
        'NL'
      else
        'BE'
    end
  end
end
