  class Director < ActiveRecord::Base
    establish_connection "development2"

    db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']

    has_friendly_id :name, :use_slug => true, :approximate_ascii => true, :cache_column => 'cached_slug' 

    has_many :products
  end
