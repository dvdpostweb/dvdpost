class MessageTicket < ActiveRecord::Base
  belongs_to :ticket

  named_scope :unread, :conditions => ["`read` = 0 and user_id > 0"]
  named_scope :custer, :conditions => ["user_id > 0"]
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :ordered, :order => "id DESC"
end