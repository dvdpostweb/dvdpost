class Product < ActiveRecord::Base
  establish_connection "development2"

  named_scope :by_support, lambda {|support| {:conditions => {:product_support_id => DVDPost.product_supports[support]}}}

  has_and_belongs_to_many :languages
  has_and_belongs_to_many :subtitles

  belongs_to :movie

  def products_next
    0
  end
  def products_availability
    0
  end
  def status
    0
  end

end