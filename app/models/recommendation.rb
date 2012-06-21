class Recommendation < ActiveRecord::Base
  belongs_to :product, :foreign_key => :recommendation_id
end