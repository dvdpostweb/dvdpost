class SurveyDetail < ActiveRecord::Base
  has_one :survey
  belongs_to :product, :primary_key => :products_id, :foreign_key => :reference_id

  def image(survey_id)
     File.join(DVDPost.images_path, 'surveys', survey_id.to_s, "images", "#{id}.jpg")
  end
  
end