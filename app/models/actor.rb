class Actor < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_primary_key :actors_id

  alias_attribute :name, :actors_name

  named_scope :limit, lambda {|limit| {:limit => limit}}

  has_and_belongs_to_many :products, :join_table => :products_to_actors, :foreign_key => :actors_id, :association_foreign_key => :products_id
end
