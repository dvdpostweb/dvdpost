class Language < ActiveRecord::Base
    establish_connection "development2"
    set_table_name :languages
    set_primary_key :id
    
    alias_attribute :title, :name

    #has_and_belongs_to_many :products
end