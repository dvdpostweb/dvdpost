class Product2 < ActiveRecord::Base
    establish_connection "development2"
    set_primary_key :id
    set_table_name :products

    has_and_belongs_to_many :languages, :join_table => :languages_products, :foreign_key => :product_id, :association_foreign_key => :language_id
    belongs_to :movie
    
end