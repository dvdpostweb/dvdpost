class ChronicleCategory < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"
  has_many :chronicles, :foreign_key => :category_id

  def image
    File.join(DVDPost.images_path, "chronicles", "categories", "#{id}.png")
  end
end