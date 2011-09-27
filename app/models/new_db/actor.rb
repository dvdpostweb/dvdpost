  class Actor < ActiveRecord::Base
    establish_connection "development2"
    
    db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']

    named_scope :limit, lambda {|limit| {:limit => limit}}
    named_scope :by_kind, lambda {|kind| {:conditions => {:movie_kind_id => DVDPost.actor_kinds[kind]}}}
    
    
    named_scope :by_sexuality, lambda {|sexuality| {:conditions => {:sexuality => sexuality.to_s}}}
    named_scope :by_letter, lambda {|letter| {:conditions => ["name like ?", letter+'%' ]}}
    named_scope :top, :conditions => 'top > 0'
    named_scope :with_image, :conditions => {:image_active => true}
    named_scope :ordered, :order => 'name'
    named_scope :top_ordered, :order => 'top desc'

#    has_friendly_id :name, :use_slug => true, :approximate_ascii => true 

    has_and_belongs_to_many :products

    def image(number = 1)
      File.join(DVDPost.imagesx_path, "actors", "#{id}_#{number}.jpg")
    end

    def top?
      top && top > 0
    end
  end
