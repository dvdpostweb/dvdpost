class StepsController < ApplicationController
  def show
    @customer = current_customer
    @address = current_customer.build_address
    @address.customers_id = current_customer.to_param
  end
end