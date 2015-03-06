class ProductAbo < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :products_abo
  set_primary_key :products_id
  
  alias_attribute :credits,    :qty_credit

  has_one :product, :foreign_key => :products_id
  
  named_scope :available, lambda {|group| {:conditions => ['allowed_public_group = ? or allowed_private_group = ?', group, group]}}
  named_scope :ordered, :order => "qty_credit ASC"
  named_scope :ordered_nl, :order => "ordered ASC"

  
  def self.get_list(group = 1)
    group == 10 ? available(group).ordered_nl :  available(group).ordered
  end

  def only_vod
    qty_dvd_max == 0
  end

  def only_dvd
    qty_dvd_max == credits
  end
end