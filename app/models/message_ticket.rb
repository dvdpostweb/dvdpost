class MessageTicket < ActiveRecord::Base
  belongs_to :ticket
  belongs_to :email, :foreign_key => :mail_id
  
  named_scope :unread, :conditions => ["`is_read` = 0 and user_id > 0"]
  named_scope :custer, :conditions => ["user_id > 0"]
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :ordered, :order => "id DESC"
  
  def unread?
    is_read == 0 && !user_id.nil?
  end
end