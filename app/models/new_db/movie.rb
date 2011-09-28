class Movie < ActiveRecord::Base
  establish_connection "development2"

  belongs_to :director, :primary_key => :id

  #belongs_to :studio, :foreign_key => :products_studio
  #belongs_to :country, :class_name => 'ProductCountry', :foreign_key => :products_countries_id
  #belongs_to :picture_format, :foreign_key => :products_picture_format, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  #has_one :public, :primary_key => :products_public, :foreign_key => :public_id, :conditions => {:language_id => DVDPost.product_languages[I18n.locale.to_s]}
  has_many :descriptions, :class_name => 'MovieDescription'
  has_and_belongs_to_many :actors
  has_and_belongs_to_many :categories
  has_many :products
  #has_and_belongs_to_many :product_lists, :join_table => :listed_products, :order => 'listed_products.order asc'
  #has_and_belongs_to_many :soundtracks, :join_table => :products_to_soundtracks, :foreign_key => :products_id, :association_foreign_key => :products_soundtracks_id

  define_index do
    indexes descriptions.name,  :as => :descriptions_text
    indexes director.name,            :as => :director_name
    indexes actors.name,                 :as => :actors_name

    has categories(:id), :as => :category_id
    has actors(:id),         :as => :actors_id
    has products.languages(:id), :as => :dvd_language_ids

    set_property :enable_star => true
    set_property :min_prefix_len => 3
    set_property :charset_type => 'sbcs'
    set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
    set_property :ignore_chars => "U+AD"
    #set_property :field_weights => {:brand_name => 10, :name_fr => 5, :name_nl => 5, :description_fr => 4, :description_nl => 4}
  end

  sphinx_scope(:by_actor)           {|actor|            {:with =>       {:actors_id => actor.to_param}}}
  sphinx_scope(:by_category)        {|category|         {:with =>       {:category_id => category.to_param}}}

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
    #if options[:kind] == :adult
    #  products = products.by_kind(:adult).available
    #else
    #  products = products.by_kind(:normal).available
    #end

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
   # if Rails.env == "production"
   #   streaming_products.available.count > 0
   # else
   #   streaming_products.count > 0
   # end  
   false
  end

  def vod?
    #media == DVDPost.product_types[:vod]
    false
  end


end
