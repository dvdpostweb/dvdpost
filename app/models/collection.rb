class Collection < ActiveRecord::Base
  set_primary_key :themes_id
  set_table_name :themes
  
  has_many :descriptions, :class_name => 'CollectionDescription', :foreign_key => :themes_id
  has_and_belongs_to_many :products, :join_table => :products_to_themes, :foreign_key => :themes_id, :association_foreign_key => :products_id

  named_scope :by_kind, lambda {|kind| {:conditions => {:themes_type => DVDPost.product_kinds[kind]}}}
  named_scope :rand, :order => 'rand()'
  named_scope :active, :conditions => {:active => 1}

  def name
    descriptions.by_language(I18n.locale).first ? descriptions.by_language(I18n.locale).first.name : "NONAME_#{to_param}"
  end
end
