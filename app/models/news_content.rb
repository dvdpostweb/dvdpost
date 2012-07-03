class NewsContent < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  belongs_to :news
  has_attached_file :cover, :styles => { :small => "369>x245" },
                            :url  => "http://private.dvdpost.com/images/news_covers/:id/:style/:basename.:extension",
                            :path => "/home/webapps/dvdpostapp/production/shared/uploaded/news/:id/:style/:basename.:extension"
  has_attached_file :thumbs, :styles => { :small => "180>x127" },
                             :url  => "http://private.dvdpost.com/images/news_thumbs/:id/:style/:basename.:extension",
                             :path => "/home/webapps/dvdpostapp/production/shared/uploaded/news_thumbs/:id/:style/:basename.:extension"
  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  named_scope :private, :conditions => {:status => 'ONLINE'}
  named_scope :beta, :conditions => {:status => ['ONLINE','TEST']}
  
end