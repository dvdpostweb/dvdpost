class Activation < ActiveRecord::Base
  set_table_name :activation_code
  set_primary_key :activation_id

  alias_attribute :name,:activation_code
  alias_attribute :expire_at, :activation_code_validto_date
  alias_attribute :duration_type, :validity_type
  alias_attribute :duration_value, :validity_value
  alias_attribute :credits, :abo_dvd_credit
  alias_attribute :next_discount_id, :next_discount
  alias_attribute :abo_type_id, :activation_products_id
  alias_attribute :next_abo_type_id, :next_abo_type
  alias_attribute :auto_stop, :abo_auto_stop_next_reconduction
  alias_attribute :created_at, :activation_date
  
  named_scope :by_name, lambda {|name| {:conditions => {:activation_code => name}}}
  named_scope :available, lambda {{:conditions => ['(activation_code_validto_date > ? or activation_code_validto_date is null) and customers_id = 0', Time.now.to_s(:db)]}}
  
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
