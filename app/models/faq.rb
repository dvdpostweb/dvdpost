class Faq < ActiveRecord::Base
  db_magic :slave => :slave01

  named_scope :ordered, :order => "ordered ASC"
end