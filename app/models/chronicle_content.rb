class ChronicleContent < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  belongs_to :chronicle

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  named_scope :by_letter, lambda {|letter| {:conditions => ["title like ?", letter+'%' ]}}
  named_scope :by_number,  {:conditions => ["studio_name REGEXP '^[0-9]'"]}
  named_scope :private, :conditions => {:status => 'ONLINE'}
  named_scope :beta, :conditions => {:status => ['ONLINE','TEST']}
  has_attached_file :cover, :styles => { :small => "237>x237" },
                            :url  => "http://private.dvdpost.com/images/chronicles/covers/:id/:style/:basename.:extension",
                            :path => "/home/webapps/dvdpostapp/production/shared/uploaded/chronicles/:id/:style/:basename.:extension"
end