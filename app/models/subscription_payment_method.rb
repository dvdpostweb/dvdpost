class SubscriptionPaymentMethod < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :customers_abo_payment_method
  set_primary_key :customers_abo_payment_method_id

  alias_attribute :name, :customers_abo_payment_method_name
end
