class Serie < ActiveRecord::Base
  set_primary_key :series_id

  alias_attribute :name, :series_name
  alias_attribute :type_id, :series_type_id

  def saga?
    type_id == 3
  end
end