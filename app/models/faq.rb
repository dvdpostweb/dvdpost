class Faq < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  named_scope :ordered, :order => "ordered ASC"
end