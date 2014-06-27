class Landing < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  has_one :product, :primary_key => :reference_id, :foreign_key => :products_id

  named_scope :order, lambda {|order| {:order => "ordered #{order}, id desc"}}
  named_scope :order_admin, lambda {|order| {:order => "id desc"}}
  
  named_scope :not_expirated, :conditions => 'expirated_date > now() or expirated_date is null'
  named_scope :private, :conditions => {:login => ['private', 'both' ]}
  named_scope :public,  :conditions => {:login => ['public', 'both' ]}
  named_scope :public_test,  :conditions => {:login => ['public_test' ]}
  named_scope :adult,  :conditions => {:login => 'adult' }
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :by_language, lambda {|language| {:conditions => {(language == :nl ? :actif_dutch : (language == :en ? :actif_english : :actif_french)) => "YES"}}}
  named_scope :by_language_beta, lambda {|language| {:conditions => {(language == :nl ? :actif_dutch : (language == :en ? :actif_english : :actif_french)) => ["BETA","YES"]}}}

  def image
    File.join(DVDPost.images_carousel_path, id.to_s+'.jpg')
  end

  def image_ipad
    File.join(DVDPost.images_carousel_ipad_path, id.to_s+'.jpg')
  end

  def image_iphone
    File.join(DVDPost.images_carousel_iphone_path, id.to_s+'.jpg')
  end

  def image_public
    File.join(DVDPost.images_carousel_path, id.to_s+'.jpg')
  end

  def image_adult
    File.join(DVDPost.images_carousel_adult_path, id.to_s+'.jpg')
  end
  
end
