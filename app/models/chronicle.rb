class Chronicle < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  belongs_to :category, :class_name => 'ChronicleCategory'
  has_many :contents, :class_name => 'ChronicleContent'
  has_many :streaming_products, :foreign_key => :imdb_id, :primary_key => :imdb_id, :conditions => {:available => 1}

  named_scope :private, :conditions => {:status => 'ONLINE'}
  named_scope :beta, :conditions => {:status => ['ONLINE','TEST']}
  named_scope :exclude, lambda {|id| {:conditions => ["id != ?", id]}}
  named_scope :selected, :conditions => {:selected => true}
  named_scope :not_selected, :conditions => {:selected => false}
  named_scope :ordered, :order => "id desc"
  named_scope :limit, lambda {|limit| {:limit => limit}}
  has_attached_file :cover, :styles => { :small => "237>x237" },
                            :url  => "http://private.dvdpost.com/images/chronicles/covers/:id/:style/:basename.:extension",
                            :path => "/home/webapps/dvdpostapp/production/shared/uploaded/chronicles/:id/:style/:basename.:extension"

end
