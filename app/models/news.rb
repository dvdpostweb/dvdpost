class News < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  belongs_to :category, :class_name => 'NewsCategory'
  has_many :contents, :class_name => 'NewsContent'
  has_many :streaming_products, :foreign_key => :imdb_id, :primary_key => :imdb_id, :conditions => {:available => 1}

  named_scope :private, :conditions => {:status => 'ONLINE'}
  named_scope :beta, :conditions => {:status => ['ONLINE','TEST']}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => DVDPost.news_kinds[kind]}}}
  named_scope :exclude, lambda {|id| {:conditions => ["news.id != ?", id]}}
  named_scope :ordered, :order => "id desc"
  named_scope :limit, lambda {|limit| {:limit => limit}}
end