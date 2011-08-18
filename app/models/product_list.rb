class ProductList < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  has_and_belongs_to_many :products, :join_table => :listed_products, :order => 'listed_products.order asc'

  named_scope :top, :conditions => {:kind => 'TOP'}
  named_scope :theme, :conditions => {:kind => 'THEME'}
  named_scope :status, :conditions => {:status => true}
  named_scope :not_highlighted, :conditions => {:home_page => false}
  named_scope :highlighted, :conditions => {:home_page => true}
  named_scope :by_language, lambda {|language| {:conditions => {:language => language}}}
  named_scope :by_style, lambda {|style| {:conditions => {:style => DVDPost.list_styles[style]}}}
  named_scope :ordered, :order => "id desc"
  named_scope :special_theme, lambda {|theme| {:conditions => {:theme_event_id => theme}}}
  

  def top?
    kind == 'TOP'
  end

  def theme?
    kind == 'THEME'
  end
end
