class Faq < ActiveRecord::Base
  db_magic :slave => :slave01 if ENV['APP'] == "1"
  named_scope :ordered, :order => "ordered ASC"
end