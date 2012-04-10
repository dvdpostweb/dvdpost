class DiscountUse < ActiveRecord::Base

  set_table_name :discount_use
  set_primary_key :discount_use_id

  alias_attribute :created_at, :discount_use_date
  alias_attribute :customer_id, :customers_id

end
