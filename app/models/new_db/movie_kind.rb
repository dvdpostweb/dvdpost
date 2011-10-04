class MovieKind < ActiveRecord::Base
  establish_connection "development2"
  set_table_name :movie_kind
end