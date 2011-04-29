class Review < ActiveRecord::Base
  cattr_reader :per_page
  @@per_page = 3

  set_primary_key :reviews_id

  alias_attribute :created_at,    :date_added
  alias_attribute :text,          :reviews_text
  alias_attribute :rating,        :reviews_rating
  alias_attribute :like_count,    :customers_best_rating
  alias_attribute :dislike_count, :customers_bad_rating
  alias_attribute :rating,        :reviews_rating

  before_create :set_created_at
  before_validation :set_defaults

  validates_presence_of :products_id
  validates_presence_of :customers_id
  validates_presence_of :text
  validates_presence_of :customers_name
  validates_inclusion_of :rating, :in => 0..5

  belongs_to :customer, :foreign_key => :customers_id
  belongs_to :product, :foreign_key => :products_id

  has_many :review_ratings, :foreign_key => :reviews_id

  default_scope :order => 'customers_best_rating DESC, customers_bad_rating ASC, date_added DESC'
  named_scope :ordered, :order => 'date_added DESC, customers_best_rating DESC, customers_bad_rating ASC'
  named_scope :approved, :conditions => :reviews_check
  named_scope :by_language, lambda {|language| {:conditions => {:languages_id => DVDPost.product_languages[language]}}}
  named_scope :by_imdb_id, lambda {|imdb_id| {:conditions => ['products.imdb_id = ?',  imdb_id]}}
  named_scope :by_customer_id, lambda {|customer_id| {:conditions => { :customers_id => customer_id }}}
  
#  define_index do
#    indexes reviews_text,                 :as => :message
#    has reviews_id,                :as => :id
#    has reviews_rating,                :as => :rating
#    
#    set_property :enable_star => true
#    set_property :min_prefix_len => 3
#    set_property :charset_type => 'sbcs'
#    set_property :charset_table => "0..9, A..Z->a..z, a..z, U+C0->a, U+C1->a, U+C2->a, U+C3->a, U+C4->a, U+C5->a, U+C6->a, U+C7->c, U+E7->c, U+C8->e, U+C9->e, U+CA->e, U+CB->e, U+CC->i, U+CD->i, U+CE->i, U+CF->i, U+D0->d, U+D1->n, U+D2->o, U+D3->o, U+D4->o, U+D5->o, U+D6->o, U+D8->o, U+D9->u, U+DA->u, U+DB->u, U+DC->u, U+DD->y, U+DE->t, U+DF->s, U+E0->a, U+E1->a, U+E2->a, U+E3->a, U+E4->a, U+E5->a, U+E6->a, U+E7->c, U+E7->c, U+E8->e, U+E9->e, U+EA->e, U+EB->e, U+EC->i, U+ED->i, U+EE->i, U+EF->i, U+F0->d, U+F1->n, U+F2->o, U+F3->o, U+F4->o, U+F5->o, U+F6->o, U+F8->o, U+F9->u, U+FA->u, U+FB->u, U+FC->u, U+FD->y, U+FE->t, U+FF->s,"
#    set_property :ignore_chars => "U+AD"
#  end
#  sphinx_scope(:by_review_id)     {|review_id|      {:with =>       {:id => review_id}}}
#  sphinx_scope(:by_ratings)         {|min, max|         {:with =>       {:rating => min..max}}}

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
