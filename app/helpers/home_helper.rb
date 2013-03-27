module HomeHelper
  def link_to_banner_image(type,theme)
    if theme && theme.banner_hp == 1 && type == 'shop'
      link_to image_tag("#{DVDPost.images_path}/themes/#{I18n.locale}/banner/#{theme.id}.gif", :alt => theme.name),  theme_path(:id => theme.to_param)
    else  
      case type
        when 'quizz'
          link_to image_tag(@quizz.image), quizzes_path
        when 'contest'
          link_to image_tag(@contest.image), contests_path
        when 'shop'
          link_to image_tag(@shop.image), shop_path(@shop.url)
        when 'stvalentin'
          link_to image_tag("#{I18n.locale}/stvalentin.gif", :alt => 'Theme st-valentin'), themes_path(:page_name => 'stvalentin')
        when 'oscar'
          link_to image_tag("#{I18n.locale}/oscar.gif", :alt => 'Theme oscar'), themes_path(:page_name => 'oscars_cesar')
        when 'facebook'
          link_to image_tag('banner_facebook.gif', :alt => 'facebook dvdpost'), DVDPost.fb_url[I18n.locale]
        when 'community'
          link_to image_tag('banner_parrainage.gif', :alt => 'parrainage dvdpost'), sponsorships_path
        else
          'other'
      end
    end
  end

  def carousel_path(carousel)
    case carousel.kind
      when 'MOVIE'
        product_path(:id => carousel.reference_id, :source => @wishlist_source[:carousel])
      when 'OTHER'
        info_path(:page_name => carousel.name)
      when 'OLD_SITE'
        remote_carousel_path(t(".url_#{carousel.id}"))
      when 'TOP', 'THEME'
        ref = carousel.reference_id.to_s
        if ref.include?(',')
          data = ref.split(',')
          id = data[DVDPost.list_languages[I18n.locale]]
        else
          id = carousel.reference_id
        end
        list_products_path(:list_id => id)
      when 'DIRECTOR'
        director_products_path(:director_id => carousel.reference_id)
      when 'ACTOR'
        actor_products_path(:actor_id => carousel.reference_id)
      when 'CATEGORY'
        category_products_path(:category_id => carousel.reference_id)
      when 'CHRONICLE'
        chronicle_path(:id => carousel.reference_id)
      when 'STREAMING_PRODUCT'
        streaming_product_path(:id => carousel.reference_id, :warning => 1)
      when 'TRAILER'
        product_trailer_path(:product_id => carousel.reference_id, :source => @wishlist_source[:recommendation_hp])
      when 'THEME_EVENT'
        theme = ThemesEvent.find(carousel.reference_id)
        theme_path(:id => theme.to_param)
      when 'SURVEY'
        new_survey_customer_survey_path(:survey_id => carousel.reference_id)
      when 'CONTEST'
        contest_path(:id => carousel.reference_id)
      when 'SHOP'
        shop_path()
      when 'STUDIO'
         studio_products_path(:studio_id => carousel.reference_id)
     when 'STUDIO_VOD'
        studio_products_path(:studio_id => carousel.reference_id, :filter => :vod)
      when 'SEARCH'
        products_path(:search => carousel.reference_id)
      when 'URL'
        eval(t("home.index.carousel_item.url_#{carousel.id}"))
      end
  end

  def customer_awards(customer, points)
    distinction=''
    if points < DVDPost.pen_points[:one]
      nb = 0
    elsif points < DVDPost.pen_points[:two] and points >= DVDPost.pen_points[:one]
      nb=1
    elsif points < DVDPost.pen_points[:three] and points >= DVDPost.pen_points[:two]
      nb=2
    elsif points < DVDPost.pen_points[:four] and points >= DVDPost.pen_points[:three]
      nb=3
    elsif points < DVDPost.pen_points[:five] and points >= DVDPost.pen_points[:four]
      nb=4
    else
      nb = 5
      if top = customer.highlight_customers.day(0).by_kind('all').last
        if top.rank <=10
          distinction ='_3'
        elsif top.rank <=30
          distinction ='_2'
        else
          distinction ='_1'
        end
        if I18n.locale == :fr
          distinction += '_fr'
        end
      end
      
    end 
    image_name ="#{nb}_pen#{distinction}.png"
    image_tag(image_name, :class => :pen)
  end

  def rating_title(nb)
    if nb > 1 
      t 'home.reviews.ratings'
    else
      t 'home.reviews.rating'
    end
  end

  def review_title(nb)
    if nb > 1 
      t 'home.reviews.critics'
    else
      t 'home.reviews.critic'
    end
  end

  def get_avatar(current_customer)
    if current_customer.customer_attribute.avatar
      customer_avatar_path(:customer_id => current_customer.id)
    else
      if current_customer.gender == 'm'
        "avatar_m.gif"
      else
        "avatar_f.gif"
      end
    end
  end

  def get_avatar_attr(current_customer, customer_attribute)
    if customer_attribute.avatar
      customer_avatar_path(:customer_id => current_customer.id)
    else
      if current_customer.gender == 'm'
        "avatar_m.gif"
      else
        "avatar_f.gif"
      end
    end
  end

end
