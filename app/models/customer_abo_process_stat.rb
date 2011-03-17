class CustomerAboProcessStat < ActiveRecord::Base
  db_magic :slave => :slave01

  set_table_name :customers_aboprocess_stats

  alias_attribute :customer_id, :customers_id

  belongs_to :customer, :foreign_key => :customers_id

end