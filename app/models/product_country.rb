class ProductCountry < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :products_countries

  set_primary_key :countries_id

  has_many :products, :foreign_key => :products_countries_id

  named_scope :visible, :conditions => {:inprod => 1}
  named_scope :order, :order => 'countries_name asc'

  def name
    self[I18n.locale]
  end
end
