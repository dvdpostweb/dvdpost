class WishlistSource < ActiveRecord::Base
  db_magic :slave => :slave01

  has_many :wishlist_items
end