class SubscriptionPaymentMethod < ActiveRecord::Base
<<<<<<< HEAD
  db_magic :slave => :slave01 if ENV['APP'] == "1"
=======
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
>>>>>>> 61b3a1dcbf05e6fb3531e34321a56a5d937ee13c

  set_table_name :customers_abo_payment_method
  set_primary_key :customers_abo_payment_method_id

  alias_attribute :name, :customers_abo_payment_method_name
end
