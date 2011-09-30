class Rating < ActiveRecord::Base
  establish_connection "development2"

  before_save :set_defaults
  after_save :set_already_seen
  #, :cache_rating

  validates_presence_of :movie
  validates_presence_of :customer
  validates_inclusion_of :value, :in => 0..5

  belongs_to :customer
  belongs_to :movie
  named_scope :by_customer, lambda {|customer| {:conditions => {:customer_id => customer.to_param}}}

  private
  def set_defaults
    self.created_at = Time.now.to_s(:db)
  end

  def set_already_seen
    MovieSeen.create(:customer_id => customer.to_param, :movie_id => movie.to_param)
  end

  def cache_rating
    movie.rate!(value)
  end
end
