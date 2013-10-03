class Review < ActiveRecord::Base
  establish_connection "common_#{Rails.env}"
  cattr_reader :per_page
  @@per_page = 3

  alias_attribute :created_at,    :date_added
  alias_attribute :text,          :reviews_text
  alias_attribute :rating,        :reviews_rating
  alias_attribute :like_count,    :customers_best_rating
  alias_attribute :dislike_count, :customers_bad_rating
  alias_attribute :rating,        :reviews_rating

  before_create :set_created_at
  before_validation :set_defaults

  validates_presence_of :imdb_id
  validates_presence_of :customers_id
  validates_presence_of :text
  validates_presence_of :customers_name
  validates_inclusion_of :rating, :in => 0..5

  belongs_to :customer, :foreign_key => :customers_id
  belongs_to :customer_attribute, :foreign_key => :customers_id, :primary_key => :customer_id
  
  belongs_to :product, :foreign_key => :imdb_id, :primary_key => :imdb_id

  has_many :review_ratings, :foreign_key => :review_id

  default_scope :order => '(customers_best_rating - customers_bad_rating ) DESC, customers_best_rating desc, date_added DESC'
  named_scope :ordered, lambda {|sorted| {:order => "#{sorted} DESC, (customers_best_rating - customers_bad_rating ) DESC, customers_best_rating DESC"}}
  named_scope :approved, :conditions => :reviews_check
  named_scope :by_language, lambda {|language| {:conditions => {:languages_id => DVDPost.product_languages[language]}}}
  named_scope :by_imdb_id, lambda {|imdb_id| {:conditions => ['reviews.imdb_id = ?',  imdb_id]}}
  named_scope :by_customer_id, lambda {|customer_id| {:conditions => { :customers_id => customer_id }}}
  
  def self.sort
    sort = OrderedHash.new
    sort.push(:date, 'date_added')
    sort.push(:rating, 'reviews_rating')
    sort
  end

  def self.sort2
    sort = OrderedHash.new
    sort.push(:interesting  , 'interesting')
    sort.push(:date, 'date_added')
    sort.push(:rating, 'reviews_rating')
    sort
  end

  def likeable_count
    like_count + dislike_count
  end

  def likeability
    like_count - dislike_count
  end

  def rating_by_customer(customer=nil)
    review_ratings.by_customer(customer).first
  end

  def set_defaults
    self.customers_name = customer.first_name
  end

  def set_created_at
    self.created_at = Time.now.to_s(:db)
  end
end
