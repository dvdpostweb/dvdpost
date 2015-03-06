class General < ActiveRecord::Base
  set_table_name :generalglobalcode
  set_primary_key :CodeType

  alias_attribute :type, :CodeType
  alias_attribute :value, :CodeValue
end