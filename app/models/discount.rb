class Discount < ActiveRecord::Base
  set_table_name :discount_code
  set_primary_key :discount_code_id
  
  alias_attribute :name,:discount_code
  alias_attribute :expire_at, :discount_validityto
  alias_attribute :step, :goto_step
  alias_attribute :type, :discount_type
  alias_attribute :value, :discount_value
  alias_attribute :duration_type, :discount_abo_validityto_type
  alias_attribute :duration_value, :discount_abo_validityto_value
  alias_attribute :recurring, :discount_recurring_nbr_of_month
  alias_attribute :credits, :abo_dvd_credit
  alias_attribute :next_discount_id, :next_discount
  alias_attribute :abo_type_id, :listing_products_allowed
  alias_attribute :next_abo_type_id, :next_abo_type
  alias_attribute :auto_stop, :abo_auto_stop_next_reconduction
  
  named_scope :by_name, lambda {|name| {:conditions => {:discount_code => name}}}
  named_scope :available, lambda {{:conditions => ['(discount_validityto > ? or discount_validityto is null) and discount_status = 1', Time.now.to_s(:db)]}}
  
  def duration
    case duration_type
    when 1
      duration_value.days.from_now.localtime
    when 2
      duration_value.months.from_now.localtime
    when 3
      duration_value.year.from_now.localtime
    end
  end
end