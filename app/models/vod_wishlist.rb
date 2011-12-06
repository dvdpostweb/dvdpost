class VodWishlist < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']
  
  has_many :products, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :streaming_products, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :tokens, :primary_key => :imdb_id, :foreign_key => :imdb_id
end
