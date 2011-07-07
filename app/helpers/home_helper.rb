module HomeHelper
  def link_to_banner_image(type,theme)
    if theme && theme.banner_hp == 1 && type == 'shop'
      link_to image_tag("#{DVDPost.images_path}/themes/#{I18n.locale}/banner/#{theme.to_param}.gif", :alt => theme.name), themes_path(:page_name => theme.name)
    else  
      case type
        when 'quizz'
          link_to image_tag(@quizz.image), quizzes_path
        when 'contest'
          link_to image_tag(@contest.image), new_contest_path
        when 'shop'
          link_to image_tag(@shop.image), shop_path(@shop.url)
        when 'stvalentin'
          link_to image_tag("#{I18n.locale}/stvalentin.gif", :alt => 'Theme st-valentin'), themes_path(:page_name => 'stvalentin')
        when 'oscar'
          link_to image_tag("#{I18n.locale}/oscar.gif", :alt => 'Theme oscar'), themes_path(:page_name => 'oscars_cesar')
        when 'facebook'
          link_to image_tag('banner_facebook.gif', :alt => 'facebook dvdpost'), fb_url
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
        product_path(:id => carousel.reference_id)
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
      when 'STREAMING_PRODUCT'
        streaming_product_path(:id => carousel.reference_id, :warning => 1)
      when 'THEME_EVENT'
        name = ThemesEvent.find(carousel.reference_id).name
        themes_path(:page_name => name)
      when 'SURVEY'
        new_survey_customer_survey_path(:survey_id => carousel.reference_id)
      when 'URL'
        eval(t(".url_#{carousel.id}"))
      end
  end

  def customer_awards(points)
    if points < 20 and points > 10
      nb=1
    elsif points < 50 and points > 20
      nb=2
    elsif points < 500 and points > 50
      nb=3
    elsif points < 1000 and points > 500
      nb=4
    else
      nb = 5
    end 
    images = ""
    nb.times do |i|
      images += image_tag "plume.jpg", :class => :plume
    end
    images
  end
  
end
