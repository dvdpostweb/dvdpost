class OgoneCheck < ActiveRecord::Base
  set_table_name :ogone_check
  
  alias_attribute :product_id, :products_id
  
  belongs_to :customer, :foreign_key => :customers_id
  belongs_to :product_abo, :foreign_key => :products_id
  belongs_to :product, :foreign_key => :products_id
  
end