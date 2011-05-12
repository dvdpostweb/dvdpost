class Survey < ActiveRecord::Base
  has_many :survey_details
  has_many :customer_surveys
  has_one :themes_event, :foreign_key => :id, :primary_key => :themes_event_id
  belongs_to :survey_kind

  def title(locale)
    case locale
    when :fr
      title_fr
    when :nl
      title_nl
    when :en
      title_en
    end
  end

  def image
    File.join(DVDPost.images_path, 'surveys', id.to_s, I18n.locale.to_s, "header.gif")
  end

  def best
    best_rating_id = survey_details.maximum(:rating)
    survey_details.find_by_rating(best_rating_id)
  end
end