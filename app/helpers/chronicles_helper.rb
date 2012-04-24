module ChroniclesHelper
  def image_rating(rating)
    img = ""
    for i in 1..5
      if i <= rating
        img << image_tag("chronicles/star-on.png")
      else
        img <<  image_tag("chronicles/star-off.png")
      end
    end
    img
  end
end
