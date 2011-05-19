class Studio < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_primary_key :studio_id

  set_table_name :studio

  alias_attribute :name, :studio_name

  named_scope :by_letter, lambda {|letter| {:conditions => ["studio_name like ?", letter+'%' ]}}
  named_scope :by_kind, lambda {|kind| {:conditions => {:studio_type => DVDPost.actor_kinds[kind]}}}
  named_scope :by_number,  {:conditions => ["studio_name REGEXP '^[0-9]'"]}
  named_scope :limit, lambda {|limit| {:limit => limit}}

  has_many :products, :foreign_key => :products_studio
end