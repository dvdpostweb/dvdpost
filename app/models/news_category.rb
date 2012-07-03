class NewsCategory < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  has_many :news, :foreign_key => :category_id
end
