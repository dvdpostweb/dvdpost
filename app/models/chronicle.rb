class Chronicle < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  belongs_to :category, :class_name => 'ChronicleCategory'
  has_many :contents, :class_name => 'ChronicleContent'

  named_scope :private, :conditions => {:status => 'ONLINE'}
  named_scope :beta, :conditions => {:status => ['ONLINE','TEST']}
  named_scope :exclude, lambda {|id| {:conditions => ["id != ?", id]}}
  named_scope :selected, :conditions => {:selected => true}
  named_scope :not_selected, :conditions => {:selected => false}
  named_scope :ordered, :order => "id desc"
  named_scope :limit, lambda {|limit| {:limit => limit}}

  def image
    File.join(DVDPost.images_path, "chronicles", "contents", "#{id}.jpg")
  end
end
