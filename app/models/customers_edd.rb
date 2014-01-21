class CustomersEdd < ActiveRecord::Base
  set_table_name :customers_edd
  belongs_to :customer, :foreign_key => :customers_id, :primary_key => :customers_id
end