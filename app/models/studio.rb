class Studio < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_primary_key :studio_id

  set_table_name :studio

  alias_attribute :name, :studio_name

  named_scope :limit, lambda {|limit| {:limit => limit}}

  has_many :products, :foreign_key => :products_studio
end