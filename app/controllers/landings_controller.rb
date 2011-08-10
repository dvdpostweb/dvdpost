class LandingsController < ApplicationController
  def index
    @landings = Landing.order_admin
  end
end