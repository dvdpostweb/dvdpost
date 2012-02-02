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

  def audio_bubbles(product, additional_bubble = 0)
    audio_count=0
    total_bubble = 5 + additional_bubble 
    preferred_audio = product.languages.preferred
    audio = Array.new
    unless preferred_audio.count == 0
      audio = preferred_audio.collect{|language| 
        audio_count +=1
        content_tag(:div, language.short.upcase, :class => "#{language.class.name.underscore} #{class_bubble(language.short)}", :alt => language.name, :title => language.name)
      }
    end
    
    not_preferred_audio = product.languages.not_preferred
    unless not_preferred_audio.count == 0
      audio << not_preferred_audio.collect{|language| 
        audio_count +=1
        display = audio_count > total_bubble ? 'audio_hide' : ''
        if language.short
          content_tag(:div, language.short.upcase, :class => "#{language.class.name.underscore} #{class_bubble(language.short)} #{display}", :alt => language.name, :title => language.name)
        else
          content_tag(:div, language.name,:class => "#{language.class.name.underscore}_text #{display}")
        end
      }
    end
    if audio_count > total_bubble
      audio << content_tag(:div, '', :class => "audio_more")
      hide = true
    else
      hide = false
    end
    {:audio => audio, :hide => hide}
  end
  

  def subtitle_bubbles(product, additional_bubble)
    subtitle_count=0
    total_bubble = 5 + additional_bubble 
    preferred_subtitle = product.subtitles.preferred
    sub = Array.new
    unless preferred_subtitle.count == 0
      sub = preferred_subtitle.preferred.collect{|subtitle| 
        subtitle_count += 1
        content_tag(:div, subtitle.short.upcase, :class => "#{subtitle.class.name.underscore} #{class_bubble(subtitle.short)}", :alt => subtitle.name, :title => subtitle.name)
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
            content_tag(:div, subtitle.short.upcase, :class => "#{subtitle.class.name.underscore} #{class_undertitle} #{display}", :alt => subtitle.name, :title => subtitle.name)
          else
            content_tag(:div, subtitle.name, :class => "#{subtitle.class.name.underscore}_text #{display}")
          end
        }
      end
      if subtitle_count > total_bubble
        sub << content_tag(:div, '', :class => "subtitle_more")
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
     rating = product.rating(current_customer) 
     links = []
     rated = current_customer ? current_customer.has_rated?(product) : nil
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
        "star-on-review.png"
      elsif rating == 1
        "star-half-review.png"
      else
        "star-off-review.png"
      end
      links << image_tag(image_name, :name => image_name)
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
    if size == 'small' || size == :small
      name = "small-#{name}"
    else
      if background == :black
        name = "black-#{name}" 
      end
    end
    if background == :pink
      name = "pink-#{name}" 
    end
    if size == 'small' || size == :small || background == :pink
      image_name = if rating >= 2
        "#{name}-on.png"
      elsif rating == 1
        "#{name}-half.png"
      else
        "#{name}-off.png"
      end
    else
      image_name = if rating >= 2
        "#{name}-on.jpg"
      elsif rating == 1
        "#{name}-half.jpg"
      else
        "#{name}-off.jpg"
      end
    end
    if current_customer && class_name == 'star'
      image = image_tag(image_name, :class => class_name, :id => "star_#{product.to_param}_#{value}", :name => image_name)
      link_to(image, product_rating_path(:product_id => product, :value => value, :background => background, :size => size, :replace => replace, :recommendation => recommendation))
    else
      image = image_tag(image_name, :class => class_name, :id => "star_#{product.to_param}_#{value}", :name => image_name)
    end
  end

  def available_on_other_media(product, recommendation)
    unless product.series?
      if product.dvd?
        bluray = product.media_alternative(:blueray)
        if bluray
          path = recommendation.to_i > 0 ? product_path(:id => bluray.to_param, :recommendation => recommendation) : product_path(:id => bluray.to_param)
          link_to(t('.dispo_bluray'), path, :id => 'bluray-btn') 
        end
      elsif product.bluray?
        dvd = product.media_alternative(:dvd)
        if dvd
          path = recommendation.to_i > 0 ? product_path(:id => dvd.to_param, :recommendation => recommendation) : product_path(:id => dvd.to_param)
          link_to(t('.dispo_dvd'), path, :id => 'dvd-btn')
        end
      else
        ''
      end
    else
      ''
    end
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
    title = "#{t '.director'}: #{Director.find(params[:director_id]).name}" if params[:director_id] && !params[:director_id].blank?
    title = "#{t '.studio'}: #{Studio.find(params[:studio_id]).name}" if params[:studio_id] && !params[:studio_id].blank?
    title = "#{t ".actor_#{params[:kind]}"}: #{Actor.find(params[:actor_id]).name}" if params[:actor_id] && !params[:actor_id].blank?
    title = t('.recommendation') if params[:view_mode] == 'recommended'
    title = t('.streaming_title') if params[:view_mode] == 'streaming'
    title = t('.popular_streaming_title') if params[:view_mode] == 'popular_streaming'
    title = t('.weekly_streaming_title') if params[:view_mode] == 'weekly_streaming'
    title = "#{t '.categorie'}: #{Category.find(params[:category_id]).descriptions.by_language(I18n.locale).first.name}" if params[:category_id] && !params[:category_id].blank?
    title = "#{t '.collection'}: #{Collection.find(params[:collection_id]).descriptions.by_language(I18n.locale).first.name}" if params[:collection_id] && !params[:collection_id].blank?
    list = ProductList.find(params[:list_id]) if params[:list_id] && !params[:list_id].blank?
    title = (list.theme? ? "#{t('.theme')}: #{list.name}" : list.name) if list
    title = "#{t '.search'}: #{params[:search]}" if params[:search]
    title
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

  def left_column_categories(selected_category, kind, sexuality, host_ok)
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
        link_to category.name, category_products_path(:category_id => category), :class => a_class
      end
      if selected_category && (category == selected_category || category == selected_category.parent)
        category.children.active.movies.by_kind(:normal).remove_themes.ordered.collect do |sub_category|
          html_content << content_tag(:li, :class => 'subcat') do
            link_to " | #{sub_category.name}", category_products_path(:category_id => sub_category), :class => ('actived' if sub_category == selected_category)
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
        kind == :adult ? link_to( t('.full_categories'), categories_path(), :id => 'catx') : link_to( t('.category_x'), root_path(:kind => :adult), :id => 'catx')
      end
    end
    html_content
  end

  def streaming_audio_bublles(product)
    content=[]
    country=[]
    content << StreamingProduct.find_all_by_imdb_id(product.imdb_id).collect{
    |product|
      if product.language.by_language(I18n.locale).first && product.language.by_language(I18n.locale).first.short
        lang = product.language.by_language(I18n.locale).first
        short = lang.short
        name = lang.name
        if !country.include?(short)
          country << short
          content_tag(:div, short.upcase, :class => "language  #{class_bubble(name)}", :alt => name, :title => name) 
        end
      end
    }
    content
  end

  def streaming_subtitle_bublles(product)
    content=[]
    country=[]
    content << StreamingProduct.find_all_by_imdb_id(product.imdb_id).collect{
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
          content_tag(:div, short.upcase, :class => "subtitle #{class_undertitle}", :alt => name, :title => name)
        end
      end
    }
    content
  end

  def bubbles(product)
    if params[:view_mode] == 'streaming'
      "#{streaming_audio_bublles(product)} #{streaming_subtitle_bublles(product)}"
    else
      audio_bubble = audio_bubbles(product, 0)
      subtitle_bubble = subtitle_bubbles(product, 0)
      separator = (audio_bubble[:hide] == true || subtitle_bubble[:hide] == true ) ? '<div style="clear:both"></div>': ''
      "#{audio_bubble[:audio]} #{separator} #{subtitle_bubble[:sub]}"
    end
  end

  def product_review_stars(review, kind)
    images = ""
    review.rating.times do
      images += image_tag "star-on-review.png"
    end
      (5-review.rating).times do
      images += image_tag "star-off-review.png"
    end
    images
  end

  def expire_fragment(product)
    id = product.to_param
    Rails.cache.delete "views/fr/products/product_1_1_#{id}"
    Rails.cache.delete "views/nl/products/product_1_1_#{id}"
    Rails.cache.delete "views/en/products/product_1_1_#{id}"
    Rails.cache.delete "views/fr/products/product_1_0_#{id}"
    Rails.cache.delete "views/nl/products/product_1_0_#{id}"
    Rails.cache.delete "views/en/products/product_1_0_#{id}"
    Rails.cache.delete "views/fr/products/product_0_1_#{id}"
    Rails.cache.delete "views/nl/products/product_0_1_#{id}"
    Rails.cache.delete "views/en/products/product_0_1_#{id}"
    Rails.cache.delete "views/fr/products/product_0_0_#{id}"
    Rails.cache.delete "views/nl/products/product_0_0_#{id}"
    Rails.cache.delete "views/en/products/product_0_0_#{id}"
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
end