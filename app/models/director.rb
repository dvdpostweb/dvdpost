class Director < ActiveRecord::Base
  db_magic :slave => :slave01 if ENV['APP'] == "1"

  set_primary_key :directors_id

  alias_attribute :name, :directors_name

  has_many :products, :foreign_key => :products_directors_id
end
