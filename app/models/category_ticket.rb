class CategoryTicket < ActiveRecord::Base
  has_many :tickets
end