class Slug < ActiveRecord::Base
  db_magic :slave => :slave01 if ENV['APP'] == "1"

end
