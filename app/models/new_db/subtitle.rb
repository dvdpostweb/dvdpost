class Subtitle < ActiveRecord::Base
  establish_connection "development2"
  #db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  has_and_belongs_to_many :products

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  named_scope :preferred, :conditions => {:undertitles_id => [1, 2, 3, 4, 15, 23]}
  named_scope :preferred_serie, :conditions => {:undertitles_id => [1, 2, 3]}
  named_scope :not_preferred, :conditions => ["id not in (?)", [1, 2, 3, 4, 15, 23]]
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
    id == 38
  end
end