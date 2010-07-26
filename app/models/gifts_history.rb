class GiftsHistory < ActiveRecord::Base
  set_table_name :mem_get_mem_gift_history
  set_primary_key :mem_get_mem_gift_history_id

  named_scope :ordered, :order => 'gift_sent desc, date desc'

  belongs_to :customer,         :foreign_key => :customers_id
  belongs_to :gift, :foreign_key => :gift_id

  before_save :init_status
  
  def init_status
    self.date = Time.now.to_s(:db)
  end
end
