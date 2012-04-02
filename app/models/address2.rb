class Address < ActiveRecord::Base
  belongs_to :customer
  after_save :history
  def belgian?
    #country_id == 21
    true
  end

  def history
    Rails.logger.debug { "@@@#{customer.to_param}" }
    address_history = customer.address_books.create(:first_name => "okdd", :last_name => "sdo", :street => self.street, :city => 'city', :postal_code => 7000)
    customer.update_attribute(:address_id, address_history.address_book_id)
  end
end