class Actor < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_primary_key :actors_id

  alias_attribute :name, :actors_name
  alias_attribute :top, :top_actors
  
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :top, :conditions => 'top_actors > 0'
  
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true 

  has_and_belongs_to_many :products, :join_table => :products_to_actors, :foreign_key => :actors_id, :association_foreign_key => :products_id

  def image
    File.join(DVDPost.imagesx_path, "actors", "#{id}.jpg")
  end
end
