class SurveyDetail < ActiveRecord::Base
  has_one :survey
  belongs_to :product, :primary_key => :products_id, :foreign_key => :reference_id
  belongs_to :actor, :primary_key => :actors_id, :foreign_key => :reference_id
  belongs_to :director, :primary_key => :directors_id, :foreign_key => :reference_id

  named_scope :ordered, :order => "rating desc"

  def image(survey_id)
     File.join(DVDPost.images_path, 'surveys', "answer", "#{id}.jpg")
  end

end