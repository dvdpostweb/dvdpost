module ProductsHelper
  def hide_wishlist_if_seen
    session[:indicator_stored] || !current_customer ? javascript_tag("$('#indicator-tips').hide();") : ''
  end

  def class_bubble(text, type = :classic)
    if type == :classic
      text.size == 3 ? 'small' : 'normal'
    else
      'special'
    end
  end

  def audio_bubbles(product, additional_bubble = 0, content = :li)
    audio_count=0
    total_bubble = 3 + additional_bubble 
    preferred_audio = product.languages.preferred
    audio = Array.new
    unless preferred_audio.count == 0
      audio = preferred_audio.collect{|language| 
        audio_count +=1
        content_tag(content, language.short.upcase, :class => "left red osc", :alt => language.name, :title => language.name)
      }
    end
  
    not_preferred_audio = product.languages.not_preferred
    unless not_preferred_audio.count == 0
      audio << not_preferred_audio.collect{|language| 
        audio_count +=1
        display = audio_count > total_bubble ? 'audio_hide' : ''
        if language.short
          content_tag(content, language.short.upcase, :class => "left red osc #{display}", :alt => language.name, :title => language.name)
        else
          content_tag(content, language.name,:class => "#{language.class.name.underscore}_text #{display}")
        end
      }
    end
    if audio_count > total_bubble
      audio << content_tag(content, '', :class => "audio_more")
      hide = true
    else
      hide = false
    end
    {:audio => audio, :hide => hide}
  end
  

  def subtitle_bubbles(product, additional_bubble, content = :li)
    subtitle_count=0
    total_bubble = 3 + additional_bubble 
    preferred_subtitle = product.subtitles.preferred
    sub = Array.new
    unless preferred_subtitle.count == 0
      sub = preferred_subtitle.preferred.collect{|subtitle| 
        subtitle_count += 1
        content_tag(content, subtitle.short.upcase, :class => "left gray osc", :alt => subtitle.name, :title => subtitle.name)
      }
    end
    if subtitle_count < total_bubble
       not_preferred_sub = product.subtitles.not_preferred
       unless not_preferred_sub.count == 0
         sub << not_preferred_sub.collect{|subtitle| 
          subtitle_count += 1
          display = subtitle_count > total_bubble ? 'subtitle_hide' : '' 
          if subtitle.short
            if subtitle.short.include?('_m')
              subtitle.short = subtitle.short.slice(0..1)
              class_undertitle = class_bubble(subtitle.short, :special)
            else
              class_undertitle = class_bubble(subtitle.short, :classic)
            end
            content_tag(content, subtitle.short.upcase, :class => "left gray osc #{display} #{class_undertitle}", :alt => subtitle.name, :title => subtitle.name)
          else
            content_tag(content, subtitle.name, :class => "#{subtitle.class.name.underscore}_text #{display}")
          end
        }
      end
      if subtitle_count > total_bubble
        sub << content_tag(content, '', :class => "subtitle_more")
        hide = true
      else
        hide = false
      end
    end
    {:sub => sub, :hide => hide}
  end

  def rating_review_image_links(product, replace=nil)
    links = []
    5.times do |i|
      i += 1
      links << rating_review_image_link(product, i, replace)
    end
    links
  end

  def rating_review_image_link(product, value, replace)
    name = 'star-voted'
    class_name = 'star'
    image_name = "#{name}-off.png"

    image = image_tag(image_name, :class => class_name, :id => "star_#{product.to_param}_#{value}", :name => image_name)
    link_to image, product_rating_path(:product_id => product, :value => value, :background => :white, :replace => replace)
  end

  def rating_image_links(product, background = nil, size = nil, replace = nil, recommendation = nil)
   if product
     rating_data = product.rating(current_customer) 
     rating = rating_data[:rating]
     rated = rating_data[:customer]
     links = []
     5.times do |i|
       i += 1
       links << rating_image_link(product, rating, i, background, size, replace, recommendation, rated)
       rating -= 2
     end
     links
   end
  end

  def review_image_links(rating)
    links = []
    5.times do |i|
      i += 1
      image_name = if rating >= 2
        "star-on.png"
      elsif rating == 1
        "star-half.png"
      else
        "star-off.png"
      end
      links << image_tag(image_name, :name => image_name, :size => '12x12')
      rating -= 2
    end
    links
  end

  def rating_image_link(product, rating, value, background = nil, size = nil, replace = nil, recommendation = nil, rated = nil)
    background = background.to_sym if background
    if current_customer
      if rated
        name = 'star-voted'
        class_name = ''
      else
        name = 'star'
        class_name = 'star'
      end
    else
       name = 'star'
       class_name = ''
    end

    image_name = if rating >= 2
      "#{name}-on.png"
    elsif rating == 1
      "#{name}-half.png"
    else
      "#{name}-off.png"
    end
    s = size == :long || size == 'long' ? '19x19' : '12x12'
    image = image_tag(image_name, :class => class_name, :id => "star_#{product.id}_#{value}", :name => image_name, :size => s)
    
    if current_customer && class_name == 'star' && !mobile_request?
      link_to(image, product_rating_path(:product_id => product, :value => value, :background => background, :size => size, :replace => replace, :recommendation => recommendation))
    else
      image
    end
  end
  def available_on_other_media_title(product, limiter = "<br />")
    bluray = product.media_alternative_all(:blueray)
    bluray3d = product.media_alternative_all(:bluray3d)
    dvd = product.media_alternative_all(:dvd)
    vod = product.streaming?(params[:kind], session[:country_id])
    content = ''
    if bluray
      content << "#{t('products.index.filters.bluray')}#{limiter}"
    end
    if bluray3d
      content << "#{t('products.index.filters.bluray3d')}#{limiter}"
    end
    if dvd
      content << "#{t('products.index.filters.dvd')}#{limiter}"
    end
    if vod
      content << "VOD#{limiter}"
    end
    content[0..-3]
  end
  def available_on_other_media(product, recommendation)
    content = ''
    unless product.series?
      if product.dvd?
        bluray = product.media_alternative(:blueray)
        bluray3d = product.media_alternative(:bluray3d)
        if bluray
          path = recommendation.to_i > 0 ? product_path(:id => bluray.to_param, :recommendation => recommendation) : product_path(:id => bluray.to_param)
          content << link_to(t('.dispo_bluray'), path, :id => 'bluray-btn')
        end
        if bluray3d
          path = recommendation.to_i > 0 ? product_path(:id => bluray3d.to_param, :recommendation => recommendation) : product_path(:id => bluray3d.to_param)
          content << link_to(t('.dispo_bluray_3d'), path, :id => 'bluray-btn') 
        end
      elsif product.bluray? 
        dvd = product.media_alternative(:dvd)
        bluray3d = product.media_alternative(:bluray3d)
        if dvd
          path = recommendation.to_i > 0 ? product_path(:id => dvd.to_param, :recommendation => recommendation) : product_path(:id => dvd.to_param)
          content << link_to(t('.dispo_dvd'), path, :id => 'dvd-btn')
        end
        if bluray3d
          path = recommendation.to_i > 0 ? product_path(:id => bluray3d.to_param, :recommendation => recommendation) : product_path(:id => bluray3d.to_param)
          content << link_to(t('.dispo_bluray_3d'), path, :id => 'bluray-btn')
        end
      elsif product.bluray3d? 
        dvd = product.media_alternative(:dvd)
        bluray = product.media_alternative(:blueray)
        if dvd
          path = recommendation.to_i > 0 ? product_path(:id => dvd.to_param, :recommendation => recommendation) : product_path(:id => dvd.to_param)
          content << link_to(t('.dispo_dvd'), path, :id => 'dvd-btn')
        end
        if bluray
          path = recommendation.to_i > 0 ? product_path(:id => bluray.to_param, :recommendation => recommendation) : product_path(:id => bluray.to_param)
          content << link_to(t('.dispo_bluray'), path, :id => 'bluray-btn')
        end
      else
        content << ''
      end
    else
      content << ''
    end
    content
  end

  def available_on_other_language(product, recommendation)
    if product.products_other_language.to_i > 0
      path = recommendation.to_i > 0 ? product_path(:id => product.products_other_language, :recommendation => recommendation) : product_path(:id => product.products_other_language)
      
      if product.languages.preferred.include?(Language.find(1))
        link_to(t('.dispo_nl'), path, :id => 'dispo-btn', :class => 'dispo-btn')
      else
        link_to(t('.dispo_fr'), path, :id => 'dispo-btn', :class => 'dispo-btn')
      end
    end
  end

  def product_description_text(product)
    product.description.nil? || product.description.text.nil? ? '' : truncate_html(product.description.text, :length => 300)
  end

  def product_image_tag(source, options={})
    image_tag (source || File.join(I18n.locale.to_s, 'image_not_found.gif')), options
  end

  def awards(description)
    content = ''
    if description
      if !description.products_awards.empty?
        awards = description.products_awards.split(/<br>|<br \/>/)
        if count_awards(awards) > 3
          content += '<p id ="oscars_text">'
          3.times do |i|
            content += "#{awards[i]}<br />"
          end
          content += '</p>'
          content += "<p id=\"oscars\">#{link_to t('.read_more'), product_awards_path(:product_id => description.products_id)}</p>"
        else
          content += "<p>#{description.products_awards}</p>"
        end
      end
    end
  end

  def count_awards(awards)
    count = 0
    awards.each do |award|
      if !award.empty?
        count += 1
      end
    end
    count
  end

  def filter_checkbox_tag(attribute, sub_attribute, checked=false)
    check_box_tag "search_filter[#{attribute}[#{sub_attribute}]]", true, checked
  end

  def products_index_title
    return "#{t '.director'}: #{Director.find(params[:director_id]).name}" if params[:director_id] && !params[:director_id].blank?
    return "#{t '.studio'}: #{Studio.find(params[:studio_id]).name}" if params[:studio_id] && !params[:studio_id].blank?
    return "#{t ".actor_#{params[:kind]}"}: #{Actor.find(params[:actor_id]).name}" if params[:actor_id] && !params[:actor_id].blank?
    return t('.cinema') if params[:view_mode] == 'cinema'
    return t('.recommendation') if params[:view_mode] == 'recommended'
    return t('.streaming_title') if params[:view_mode] == 'streaming'
    return t('.popular_streaming_title') if params[:view_mode] == 'popular_streaming'
    return t('.weekly_streaming_title') if params[:view_mode] == 'weekly_streaming'
    return t('.most_rent_vod') if params[:sort] == 'token_month' && params[:filter] == 'vod'
    return t('.ppv') if params[:ppv] == '1'
    return t(".index_rating#{params[:filter]}") if params[:highlight_best_vod] == '1' || params[:highlight_best] == '1' || (params[:limit] == "50")
    return "#{t ".categorie#{params[:filter]}"}: #{Category.find(params[:category_id]).descriptions.by_language(I18n.locale).first.name}" if params[:category_id] && !params[:category_id].blank?
    return "#{t '.collection'}: #{Collection.find(params[:collection_id]).descriptions.by_language(I18n.locale).first.name}" if params[:collection_id] && !params[:collection_id].blank?
    return "#{t '.search'}: #{params[:search]}" if params[:search]
    return t(".hearts_vod") if (params[:list_id] && (params[:list_id].to_i == DVDPost.favorite_vod[I18n.locale]))
    return t(".hearts") if (params[:list_id] && (params[:list_id].to_i == DVDPost.favorite_dvd[I18n.locale]))
    return t(".fresh_vod") if params[:view_mode] == 'vod_recent'
    return t(".vod_recent") if params[:sort] == 'production_year_vod' && params[:filter] == 'vod'
    return t(".recent_all") if params[:sort] == 'production_year_all'
    return t(".fresh") if params[:view_mode] == 'recent'
    return t(".soon") if params[:view_mode] == 'soon'
    return t(".vod_soon") if params[:view_mode] == 'vod_soon'
    return t(".most_viewed") if params[:sort] == 'most_viewed'
    
    list = ProductList.find(params[:list_id]) if params[:list_id] && !params[:list_id].blank?
    return (list.theme? ? "#{t('.theme')}: #{list.name}" : list.name) if list
    return t('products.left_column.all')
  end

  def title_add_to_wishlist(type_text, type_button, media = nil)
    if type_button == :reserve
      if type_text == :short
        t('products.wishlist.short_reserve')
      else
        t('products.wishlist.reserve', :media => t("products.index.filters.#{media}"))
      end
    else
      if type_text == :short
        t('products.wishlist.short_add')
      else
        t('products.wishlist.add', :media => t("products.index.filters.#{media}"))
      end
    end  
  end

  def title_add_all_to_wishlist(type_button)
    if type_button == :reserve
      t('.reserve_serie')
    else
      t('.add_serie')
    end  
  end

  def title_remove_from_wishlist(type_text, media)
    if type_text == :short
      t('products.wishlist.short_remove')
    else
      t('products.wishlist.remove', :media => t("products.index.filters.#{media}"))
    end
  end

  def left_column_categories(selected_category, kind, sexuality, host_ok, view_mode)
    html_content = []
    cat = Category.active.roots.movies.by_kind(kind).remove_themes.ordered
    cat.collect do |category|
      li_style = 'display:none' if selected_category && category != selected_category && category != selected_category.parent && selected_category.active == 'YES'
      if category == selected_category
        a_class = 'actived'
      else
        li_class = 'cat'
      end
      html_content << content_tag(:li, :class => li_class, :style => li_style) do
        link_to category.name, category_products_path(:category_id => category, :view_mode => view_mode), :class => a_class
      end
      if selected_category && (category == selected_category || category == selected_category.parent)
        category.children.active.movies.by_kind(:normal).remove_themes.ordered.collect do |sub_category|
          html_content << content_tag(:li, :class => 'subcat') do
            link_to " | #{sub_category.name}", category_products_path(:category_id => sub_category, :view_mode => view_mode), :class => ('actived' if sub_category == selected_category)
          end
        end
        html_content << content_tag(:li) do
          link_to t('.category_back'), products_path, :id => 'all_categorie'
        end
      end
    end
    if host_ok == '0'
    li_style = selected_category ? 'display:none' : ''
      html_content << content_tag(:li, :class => :cat, :style => li_style) do
        kind == :adult ? link_to( t('.full_categories'), categories_path(:view_mode => view_mode), :id => 'catx') : link_to( t('.category_x'), root_path(:kind => :adult), :id => 'catx')
      end
    end
    html_content
  end

  def streaming_audio_bublles(product, vod_next = false)
    content=[]
    country=[]
    bubble = vod_next ? StreamingProduct.not_yet_available.find_all_by_imdb_id(product.imdb_id) : StreamingProduct.available.find_all_by_imdb_id(product.imdb_id)
    content << bubble.collect{
    |product|
      if product.language.by_language(I18n.locale).first && product.language.by_language(I18n.locale).first.short
        lang = product.language.by_language(I18n.locale).first
        short = lang.short
        name = lang.name
        if !country.include?(short)
          country << short
          content_tag(:li, short.upcase, :class => "left red osc", :alt => name, :title => name) 
        end
      end
    }
    content
  end

  def streaming_subtitle_bublles(product, vod_next = false)
    content=[]
    country=[]
    bubble = vod_next ? StreamingProduct.not_yet_available.find_all_by_imdb_id(product.imdb_id) : StreamingProduct.available.find_all_by_imdb_id(product.imdb_id)
    content << bubble.collect {
    |product|
      if product.subtitle.by_language(I18n.locale).first && product.subtitle.by_language(I18n.locale).first.short
        lang = product.subtitle.by_language(I18n.locale).first
        short = lang.short
        name = lang.name
        
        if !country.include?(short)
          country << short
          if short.include?('_m')
            short = short.slice(0..1)
            class_undertitle = class_bubble(short, :special)
          else
            class_undertitle = class_bubble(short, :classic)
          end
          content_tag(:li, short.upcase, :class => "left gray osc #{class_undertitle}", :alt => name, :title => name)
        end
      end
    }
    content
  end

  def bubbles(product)
    if params[:view_mode] == 'streaming' || params[:vod] == 'vod' || params[:filter] == 'vod'
      "#{streaming_audio_bublles(product)} #{streaming_subtitle_bublles(product)}"
    else
      audio_bubble = audio_bubbles(product, 0)
      subtitle_bubble = subtitle_bubbles(product, 0)
      separator = '' #(audio_bubble[:hide] == true || subtitle_bubble[:hide] == true ) ? '<div style="clear:both"></div>': ''
      "#{audio_bubble[:audio]} #{separator} #{subtitle_bubble[:sub]}"
    end
  end

  def product_review_stars(review, kind)
    images = ""
    review.rating.times do
      images += image_tag "star-on.png", :size => '13x13'
    end
      (5-review.rating).times do
      images += image_tag "star-off.png", :size => '13x13'
    end
    images
  end

  def green_stars(rating)
    images = ""
    rating.times do
      images += image_tag "green-star-on.png", :size => '21x20'
    end
      (5-rating).times do
      images += image_tag "green-star-off.png", :size => '21x20'
    end
    images
  end

  def expire_fragment(product)
    id = product.id
    Rails.cache.delete "views/fr/products/product2_1_1_#{id}"
    Rails.cache.delete "views/nl/products/product2_1_1_#{id}"
    Rails.cache.delete "views/en/products/product2_1_1_#{id}"
    Rails.cache.delete "views/fr/products/product2_1_0_#{id}"
    Rails.cache.delete "views/nl/products/product2_1_0_#{id}"
    Rails.cache.delete "views/en/products/product2_1_0_#{id}"
    Rails.cache.delete "views/fr/products/product2_0_1_#{id}"
    Rails.cache.delete "views/nl/products/product2_0_1_#{id}"
    Rails.cache.delete "views/en/products/product2_0_1_#{id}"
    Rails.cache.delete "views/fr/products/product2_0_0_#{id}"
    Rails.cache.delete "views/nl/products/product2_0_0_#{id}"
    Rails.cache.delete "views/en/products/product2_0_0_#{id}"
  end

  def abo_details(abo, free_upgrade=0)
    if abo.qty_dvd_max == 0
      details = "<strong>#{pluralize(abo.credits, t('.in_vod'), t('.in_vods'))}</strong>"
    else
      details =""
      details = "<strong>#{abo.qty_dvd_max} #{t '.films'}</strong> #{t '.all_formats'}"
      details += "<strong> + #{pluralize(abo.credits - abo.qty_dvd_max, t('.in_vod'), t('.in_vods'))}</strong>"
      details += "<br /> #{image_tag "freeupgradelogo.gif"}" if abo.ordered == free_upgrade 
    end
    details
  end

  def left_column_vod(params)
    html_content = []
    #if params[:kind] == :normal
    #  html_content << content_tag(:li, :class => :list) do
    #    link_to t('products.left_column.ppv'), products_path(:filter => :vod, :ppv => 1), :class => params[:filter] == "vod" && params[:ppv] == "1" ? :actived : ''
    #  end
    #end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.rent'), products_path(:filter => :vod, :sort => :token_month, :limit => 20), :class => params[:filter] == "vod" && params[:sort] == "token_month" ? :actived : ''
    end
    if params[:kind] == :adult
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.rating'), products_path(:sort => :rating, :limit => 50, :filter => :vod), :class => params[:highlight_best_vod] == "1" ? :actived : ''
      end
    else
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.rating'), products_path(:highlight_best_vod => 1, :filter => :vod), :class => params[:highlight_best_vod] == "1" ? :actived : ''
      end
    end
    if params[:kind] == :adult
      list = ProductList.theme.by_kind(params[:kind].to_s).by_style(:vod).find_by_home_page(true)
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.favorite'), list_products_path(:list_id => list.to_param), :class => params[:list_id].to_i == list.to_param ? :actived : ''
      end
    else
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.favorite'), list_products_path(:list_id => DVDPost.favorite_vod[I18n.locale]), :class => params[:list_id].to_i == DVDPost.favorite_vod[I18n.locale] ? :actived : ''
      end
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.new'), products_path(:sort => :production_year_vod, :filter => :vod), :class => params[:filter] == "vod" && params[:sort] == 'production_year_vod' ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.fresh_vod'), products_path(:view_mode => :vod_recent, :filter => :vod), :class => params[:filter] == "vod" && params[:view_mode] == "vod_recent" ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.soon'), products_path(:view_mode => :vod_soon, :filter => :vod), :class => params[:filter] == "vod" && params[:view_mode] == "vod_soon" ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.categorie'), categories_path(:filter => :vod), :class => params[:controller] == "categories" && params[:filter] == "vod" ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.studio'), studios_path(:filter => :vod), :class => params[:controller] == "studios" && params[:filter] == "vod" && params[:id] != 804 ? :actived : ''
    end
    if params[:kind] == :normal
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.univercine'), studio_products_path(:studio_id => 804, :filter => :vod), :class => params[:controller] == "studios" && params[:filter] == "vod" && params[:id] == 804 ? "actived" : ''
      end
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.all_catalogue'), products_path(:view_mode => :streaming), :class => params[:view_mode] == "streaming"  ? :actived : ''
    end
    
  end

  def left_column(params)
    html_content = []
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.rent'), products_path(:sort => :most_viewed, :limit => 20), :class => params[:filter] != "vod" && params[:sort] == "most_viewed" ? :actived : ''
    end
    if params[:kind] == :adult
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.rating'), products_path(:sort => :rating, :limit => 50), :class => params[:highlight_best] == "1" ? :actived : ''
      end
    else
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.rating'), products_path(:highlight_best => 1), :class => params[:highlight_best] == "1" ? :actived : ''
      end
    end
    unless params[:kind] == :adult
      html_content << content_tag(:li, :class => :list) do
        link_to t('products.left_column.favorite'), list_products_path(:list_id => DVDPost.favorite_dvd[I18n.locale]), :class => params[:list_id].to_i == DVDPost.favorite_dvd[I18n.locale] ? :actived : ''
      end
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.new'), products_path(:sort => :production_year_all), :class => params[:sort] == 'production_year_all' ? :actived : ''
    end
    
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.fresh'), products_path(:view_mode => :recent), :class => params[:filter] != "vod" && params[:view_mode] == "recent" ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.soon'), products_path(:view_mode => :soon), :class => params[:filter] != "vod" && params[:view_mode] == "soon" ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.cinema'), products_path(:view_mode => :cinema), :class => params[:view_mode] == "cinema" ? :actived : ''
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.categorie'), categories_path(), :class => params[:controller] == "categories"  && params[:filter] != "vod" ? :actived : ''
    end
    if params[:kind] == :adult
      html_content << content_tag(:li, :class => :list) do
        link_to t('.performers'), actors_path()
      end
    end
    html_content << content_tag(:li, :class => :list) do
      link_to t('products.left_column.all_catalogue'), products_path(), :class => params[:view_mode].nil? && params[:filter].nil? && params[:limit].nil? && params[:controller] == 'products' ? :actived : ''
    end
  end

  def human_birth(people)
    if people.birth_at
      date = Date.parse(people.birth_at)
      str = "<b>#{t '.birth_at'} :</b> #{date.strftime('%d/%m/%Y') }"
      str += " #{t '.at'} #{people.birth_place}<br>" if people.birth_place
    end
    str
  end

  def human_death(people)
    if people.death_at
      str = "<b>#{t '.death_at'} :</b> #{people.death_at.strftime('%d/%m/%Y') }"
      str += " #{t '.at'} #{people.death_place}<br>" if people.death_place
    end
    str
  end

  def category(product, cat)
    if cat
      cat.name
    else
      if product.adult?  
        product.categories.first.name unless product.categories.empty?
      else
        product.categories.active.first.name unless product.categories.active.empty?
      end
    end
  end
end