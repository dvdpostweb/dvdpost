class Public < ActiveRecord::Base
  set_table_name :public

  set_primary_key :public_id

  alias_attribute :description, :public_name

  belongs_to :product

  def name
    DVDPost.local_product_publics[to_param.to_i]
  end

  def image
    "public_#{name}.gif"
  end
end
