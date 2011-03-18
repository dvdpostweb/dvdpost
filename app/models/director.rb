class Director < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_primary_key :directors_id

  alias_attribute :name, :directors_name

  has_many :products, :foreign_key => :products_directors_id
end
