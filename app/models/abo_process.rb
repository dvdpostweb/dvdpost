class AboProcess < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :aboprocess

  set_primary_key :aboprocess_id

  alias_attribute :customer_id, :customers_id

  named_scope :today,  lambda {{:conditions => {:date_start => Time.now.midnight..(Time.now.end_of_day)}}}
  
  def finished?
    date_start != date_end && date_end.to_time < 2.hour.from_now.to_time
  end
end