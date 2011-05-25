class CollectionDescription < ActiveRecord::Base
  set_table_name :themes_description
  
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  alias_attribute :name, :themes_name

  belongs_to :collection

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  

end
