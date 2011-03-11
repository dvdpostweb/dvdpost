class Landing < ActiveRecord::Base
  has_one :product, :primary_key => :reference_id, :foreign_key => :products_id

  named_scope :order, lambda {|order| {:order => "ordered #{order}"}}
  named_scope :not_expirated, :conditions => 'expirated_date > now() or expirated_date is null'
  named_scope :private, :conditions => {:login => [1, 3]}
  named_scope :public,  :conditions => {:login => [1, 2]}
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :by_language, lambda {|language| {:conditions => {(language == :nl ? :actif_dutch : (language == :en ? :actif_english : :actif_french)) => "YES"}}}
  named_scope :by_language_beta, lambda {|language| {:conditions => {(language == :nl ? :actif_dutch : (language == :en ? :actif_english : :actif_french)) => ["BETA","YES"]}}}

  def image
    File.join(DVDPost.images_carousel_path, id.to_s+'.jpg')
  end
end
