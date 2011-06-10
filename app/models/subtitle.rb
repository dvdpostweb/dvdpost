class Subtitle < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :products_undertitles

  set_primary_key :undertitles_id

  alias_attribute :name, :undertitles_description

  has_and_belongs_to_many :products, :join_table => :products_to_undertitles, :foreign_key => :products_undertitles_id, :association_foreign_key => :products_id

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  named_scope :preferred, :conditions => {:undertitles_id => [1, 2, 3, 4, 15, 23]}
  named_scope :not_preferred, :conditions => ["undertitles_id not in (?)", [1, 2, 3, 4, 15, 23]]
  named_scope :limit, lambda {|limit| {:limit => limit}}
  

  def code
    case id
    when 1
      'fr'
    when 2
      'nl'
    when 3
      'en'
    else
      ''
    end
  end

  def without_sub?
    Rails.logger.debug { "@@@#{id}" }
    id == 38
  end
end
