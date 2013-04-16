class StreamingTrailer < ActiveRecord::Base
  has_many :subtitles, :foreign_key => :undertitles_id, :primary_key => :subtitle_id
  has_many :languages, :foreign_key => :languages_id, :primary_key => :language_id
  has_one :tokens_trailer, :foreign_key => :filename, :primary_key => :filename
  named_scope :available, lambda {{:conditions => ['available = ? and status = "online_test_ok"', 1]}}
  named_scope :available_beta, lambda {{:conditions => ['status != "deleted"', 1]}}
  named_scope :prefered_audio, lambda {|language_id| {:conditions => {:language_id => language_id }}}
  named_scope :sub_nil, lambda {|language_id| {:conditions => {:subtitle_id => nil }}}
  
  named_scope :prefered_subtitle, lambda {|subtitle_id| {:conditions => ['subtitle_id = ? and language_id <> ?', subtitle_id, subtitle_id ]}}
  named_scope :not_prefered, lambda {|language_id| {:conditions => ["language_id != :language_id and (subtitle_id != :language_id or subtitle_id is null)",{:language_id => language_id}]}}
  
  def self.get_best_version(imdb_id, local)
    if Rails.env == "production"
      streaming = available.prefered_audio(DVDPost.customer_languages[local]).sub_nil.find_by_imdb_id(imdb_id)
      if streaming.nil?
        streaming = available.prefered_audio(DVDPost.customer_languages[local]).find_by_imdb_id(imdb_id)
      end
      if streaming.nil?
        streaming = available.prefered_subtitle(DVDPost.customer_languages[local]).find_by_imdb_id(imdb_id)
      end
      if streaming.nil?
        streaming = available.prefered_audio(DVDPost.customer_languages[:en]).find_by_imdb_id(imdb_id)
      end
      if streaming.nil?
        streaming = available.find_by_imdb_id(imdb_id)
      end
    else
      streaming = available_beta.find_by_imdb_id(imdb_id)
    end
    streaming
  end

  def is_new?
    true
  end

  def url
    false
  end
end