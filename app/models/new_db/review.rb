class Review < ActiveRecord::Base
  establish_connection "development2"
  cattr_reader :per_page
  @@per_page = 3

  validates_presence_of :movie_id
  validates_presence_of :customer_id
  validates_presence_of :text
  validates_inclusion_of :rating, :in => 0..5

  belongs_to :customer
  belongs_to :movie

  default_scope :order => 'like_count DESC, dislike_count ASC, created_at DESC'
  named_scope :ordered, lambda {|sorted| {:order => "#{sorted} DESC, like_count DESC, created_at ASC"}}
  named_scope :approved, :conditions => {:check => true}
  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  named_scope :by_customer_id, lambda {|customer_id| {:conditions => { :customer_id => customer_id }}}
  
  def self.sort
    sort = OrderedHash.new
    sort.push(:date, 'created_at')
    sort.push(:rating, 'rating')
    sort
  end

  def self.sort2
    sort = OrderedHash.new
    sort.push(:interesting  , 'interesting')
    sort.push(:date, 'created_at')
    sort.push(:rating, 'rating')
    sort
  end

  def likeable_count
    like_count + dislike_count
  end

  def likeability
    like_count - dislike_count
  end

  def rating_by_customer(customer=nil)
    customer.ratings.find_by_movie_id(movie_id) if customer
  end
end
