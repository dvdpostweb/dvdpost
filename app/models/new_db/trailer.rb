class Trailer < ActiveRecord::Base
  establish_connection "development2"

  #db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  belongs_to :moive

  named_scope :by_language, lambda {|language| {:conditions => {:language_id => DVDPost.product_languages[language]}}}

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

end
