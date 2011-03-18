class WishlistSource < ActiveRecord::Base
  db_magic :slave => :slave01 if ENV['APP'] == "1"

  has_many :wishlist_items
end