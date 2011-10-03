class Product < ActiveRecord::Base
  establish_connection "development2"

  named_scope :by_dvd, :conditions => {:product_support_id => 1}

  has_and_belongs_to_many :languages

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