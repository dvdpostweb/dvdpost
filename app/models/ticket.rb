class Ticket < ActiveRecord::Base
  belongs_to :category_ticket
  has_many :message_tickets
  belongs_to :customer, :foreign_key => :customers_id

  named_scope :ordered, :order => 'id desc'
  named_scope :active, :conditions => {:remove => false}
end