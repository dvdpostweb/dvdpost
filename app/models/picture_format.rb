class PictureFormat < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :picture_format

  set_primary_key :picture_format_id

  alias_attribute :name, :picture_format_name

  has_many :products, :foreign_key => :products_picture_format

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language.to_s]}}}
end
