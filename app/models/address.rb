class Address < ActiveRecord::Base
  set_table_name :address_book
  #set_primary_key :customers_id

  before_save :replace_semicolon
  before_create :set_default
  #attr_accessible :first_name, :last_name, :street, :postal_code, :city, :country_id, :customers_id, :entry_country_id, :entry_gender, :address_book_id
  belongs_to :customer, :foreign_key => :customers_id
  alias_attribute :first_name, :entry_firstname
  alias_attribute :last_name, :entry_lastname
  alias_attribute :street, :entry_street_address
  alias_attribute :postal_code, :entry_postcode
  alias_attribute :city, :entry_city
  alias_attribute :country_id, :entry_country_id
  alias_attribute :gender, :entry_gender

  validates_length_of :first_name, :minimum => 2
  validates_length_of :last_name, :minimum => 2
  validates_length_of :street, :minimum => 5
  validates_length_of :postal_code, :minimum => 4
  validates_length_of :city, :minimum => 1

  def replace_semicolon
    self.street = self.street.gsub(/;/, ' ').gsub(/   /,' ').gsub(/  /,' ')
  end

  def belgian?
    country_id == 21
  end

  def luxemburg?
    country_id == 124
  end

  def nederlands?
    country_id == 150
  end

  def name
    "#{first_name} #{last_name}"
  end

  private
   def set_default
     self.address_book_id = customer.addresses.count > 0 ? customer.addresses.maximum(:address_book_id) + 1 : 1
     self.gender = customer.gender unless self.gender
     self.entry_country_id = customer.address ? customer.address.entry_country_id : 21
     self.first_name = customer.first_name unless self.first_name
     self.last_name = customer.last_name unless self.last_name
     
   end
   
   
end
