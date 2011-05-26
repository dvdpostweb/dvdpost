class Actor < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_primary_key :actors_id

  alias_attribute :name, :actors_name
  alias_attribute :top, :top_actors
  
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :by_kind, lambda {|kind| {:conditions => {:actors_type => DVDPost.actor_kinds[kind]}}}
  named_scope :by_sexuality, lambda {|sexuality| {:conditions => {:sexuality => sexuality.to_s}}}
  named_scope :by_letter, lambda {|letter| {:conditions => ["actors_name like ?", letter+'%' ]}}
  named_scope :top, :conditions => 'top_actors > 0'
  named_scope :with_image, :conditions => {:image_active => true}
  named_scope :ordered, :order => 'actors_name'
  named_scope :top_ordered, :order => 'top_actors desc'
  
  has_friendly_id :name, :use_slug => true, :approximate_ascii => true 

  has_and_belongs_to_many :products, :join_table => :products_to_actors, :foreign_key => :actors_id, :association_foreign_key => :products_id

  def image(number = 1)
    File.join(DVDPost.imagesx_path, "actors", "#{id}_#{number}.jpg")
  end

  def top?
    top && top > 0
  end
end
