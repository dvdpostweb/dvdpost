class LandingsController < ApplicationController
  before_filter :http_authenticate
  
  def index
    @landings = Landing.order_admin
  end
end