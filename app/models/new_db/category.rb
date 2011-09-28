class Category < ActiveRecord::Base
  establish_connection "development2"
  
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  belongs_to :parent, :class_name => 'Category', :foreign_key => :parent_id
  #has_many :descriptions, :class_name => 'CategoryDescription', :foreign_key => :categories_id
  has_and_belongs_to_many :products
  has_many :children, :class_name => 'Category', :foreign_key => :parent_id

  named_scope :by_kind, lambda {|kind| {:conditions => {:movie_kind_id => DVDPost.category_kinds[kind]}}}
  named_scope :roots, :conditions => {:parent_id => 0}
  #named_scope :visible_on_homepage, :conditions => {:show_home => 'YES'}
  named_scope :active, :conditions => {:active => 1}
  named_scope :remove_themes, :conditions => 'id != 105'
  named_scope :hetero, :conditions => 'id != 76'
  
  named_scope :ordered, :order => 'display_group ASC, sort_order ASC'
  #named_scope :alphabetic_orderd, :order => 'categories_description.categories_name'
  named_scope :by_size, :conditions => ["tag_size > 0"]
  named_scope :random, :order => 'rand()'

  #def name
    #descriptions.by_language(I18n.locale).first.name
  #end

  def root?
    parent_id == 0
  end
end