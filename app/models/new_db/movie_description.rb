class MovieDescription < ActiveRecord::Base
  establish_connection "development2"

  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  alias_attribute :title,   :name
  alias_attribute :image,   :picture
  alias_attribute :text,   :description

  belongs_to :product

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}

  def self.seo
    MovieDescription.find(:all, :conditions => ['name is not null and products_name !=""']).each do |p|
       #connection.execute("update products_description set cached_name ='#{p.title.parameterize.to_s}' where products_id = #{p.products_id} and language_id = #{p.language_id}")
    end
  end

  def full_url
    #File.join('http://', url)
    ""
  end

  def url_present?
    #url? && !url.empty?
    false
  end
end