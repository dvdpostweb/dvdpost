class CustomerAboProcessStat < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :customers_aboprocess_stats_new 

  alias_attribute :customer_id, :customers_id

  belongs_to :customer, :foreign_key => :customers_id

end