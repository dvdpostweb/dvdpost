class Ticket < ActiveRecord::Base
  belongs_to :category_ticket
  has_many :message_tickets
  belongs_to :customer, :foreign_key => :customers_id

  def self.filter
    filter = OrderedHash.new
    filter.push(:archive, 'archive')
    filter.push(:current, 'current')
    filter
  end  

  named_scope :ordered, :order => 'id desc'
  named_scope :by_kind, lambda {|kind| {:conditions => {:remove => kind}}}
end