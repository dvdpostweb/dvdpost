class StreamingProductsFree < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :streaming_products_free

  named_scope :available, lambda {{:conditions => ['available = ? and available_from < ? and expire_at > ?', 1, Time.now.to_s(:db), Time.now.to_s(:db)]}}
  named_scope :by_imdb_id, lambda {|imdb_id| {:conditions => {:imdb_id => imdb_id}}}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => kind}}}
end
