class Category < ActiveRecord::Base
  establish_connection "development2"
  set_primary_key :id
end