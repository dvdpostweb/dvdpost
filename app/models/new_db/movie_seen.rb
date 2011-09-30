class MovieSeen < ActiveRecord::Base
  establish_connection "development2"
  set_table_name :movie_seen
end