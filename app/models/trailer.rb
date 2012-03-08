class Trailer < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  set_table_name :products_trailers

  set_primary_key :trailers_id

  alias_attribute :broadcast_service, :broadcast
  alias_attribute :remote_id, :trailer

  belongs_to :product, :foreign_key => :products_id

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}
  named_scope :focus, :conditions => {:focus => true}

  def is_new?
    created_at > 3.months.ago if created_at
  end

  def url
    broadcast_url = DVDPost.trailer_broadcasts_urls[broadcast_service]
    broadcast_url ? broadcast_url + remote_id : nil
  end

  def youtube?
    broadcast_service == 'YOUTUBE'
  end

  def dailymotion?
    broadcast_service == 'DAYLYMOTION'
  end

  def film1?
    broadcast_service == 'FILM1'
  end

  def allocine?
    broadcast_service == 'ALLOCINE'
  end

  def commeaucinema?
    broadcast_service == 'COMMEAUCINEMA'
  end

  def cinemovies?
    broadcast_service == 'CINEMOVIES'
  end

  def cinenews?
    broadcast_service == 'CINENEWS.BE'
  end

  def aamreviews?
    broadcast_service == 'AAMREVIEWS'
  end

  def dorcel?
    broadcast_service == 'DORCELVISION'
  end

  def ecranlarge?
    broadcast_service == 'ECRANLARGE'
  end

  def imineo?
    broadcast_service == 'IMINEO'
  end

  def dorcel_mp4?
    broadcast_service == 'DORCEL_MP4'
  end
end
