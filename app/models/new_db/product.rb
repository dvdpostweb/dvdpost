class Product < ActiveRecord::Base
    establish_connection "development2"
    set_primary_key :id

    has_and_belongs_to_many :languages
    
end