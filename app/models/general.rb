class General < ActiveRecord::Base
  set_table_name :generalglobalcode

  alias_attribute :type, :CodeType
  alias_attribute :value, :CodeValue
end