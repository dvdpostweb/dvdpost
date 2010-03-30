class Category < ActiveRecord::Base
  establish_connection :dvdpost_main

  set_primary_key :categories_id

  has_many :descriptions, :class_name => 'CategoryDescription', :foreign_key => :categories_id
  has_and_belongs_to_many :products, :join_table => :products_to_categories, :foreign_key => :categories_id, :association_foreign_key => :products_id

  def name
    descriptions.by_language(I18n.locale).first.name
  end
end
