module ReviewsHelper
  def new_position(product_rate) 
    if product_rate.position.nil?
      "<span class='stat new'>#{image_tag( 'new.png', :alt =>'new')} &nbsp;</span>"
    elsif product_rate.position == 0
      "<span class='stat no-change'>#{image_tag( 'no-change.png', :alt =>'not change')} &nbsp;</span>"
    elsif product_rate.position > 0
      "<span class='stat up'>#{image_tag( 'up.png', :alt =>'up')} +#{product_rate.position}</span>"
    else
      "<span class='stat down'>#{image_tag( 'down.png', :alt =>'down')} #{product_rate.position}</span>"
    end
  end
end
