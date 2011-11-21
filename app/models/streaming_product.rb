class StreamingProduct < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1"

  has_many :subtitle, :foreign_key => :undertitles_id, :primary_key => :subtitle_id
  has_many :language, :foreign_key => :languages_id, :primary_key => :language_id
  has_many :tokens, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :products, :primary_key => :imdb_id, :foreign_key => :imdb_id, :limit => 1
  has_many :subtitles, :primary_key => :subtitle_id, :foreign_key => :undertitles_id
  has_many :languages, :foreign_key => :languages_id, :primary_key => :language_id
  belongs_to :studio, :foreign_key => :studio_id
  named_scope :by_filename, lambda {|filename| {:conditions => {:filename => filename}}}
  named_scope :by_version, lambda {|language_id, subtitle_id| {:conditions => {:language_id => language_id, :subtitle_id => subtitle_id}}}
  named_scope :by_language, lambda {|language_id| {:conditions => {:language_id => language_id}}}
  
  named_scope :available, lambda {{:conditions => ['available = ? and available_from < ? and streaming_products.expire_at > ? and status = "online_test_ok"', 1, Time.now.to_s(:db), Time.now.to_s(:db)]}}
  named_scope :available_beta, lambda {{:conditions => ['available = ?', 1]}}
  named_scope :prefered_audio, lambda {|language_id| {:conditions => {:language_id => language_id }}}
  named_scope :prefered_subtitle, lambda {|subtitle_id| {:conditions => ['subtitle_id = ? and language_id <> ?', subtitle_id, subtitle_id ]}}
  named_scope :not_prefered, lambda {|language_id| {:conditions => ["language_id != :language_id and (subtitle_id != :language_id or subtitle_id is null)",{:language_id => language_id}]}}
  named_scope :alpha, :conditions => {:source => 'ALPHANETWORKS'}
  
  named_scope :group_by_version, :group => 'language_id, subtitle_id'
  named_scope :group_by_language, :group => 'language_id'
  named_scope :ordered, :order => 'quality asc'
  
  def self.get_prefered_streaming_by_imdb_id(imdb_id, local)
    if Rails.env == "production"
      streaming = available.prefered_audio(DVDPost.customer_languages[local]).find_all_by_imdb_id(imdb_id)
      streaming += available.prefered_subtitle(DVDPost.customer_languages[local]).find_all_by_imdb_id(imdb_id)
    else
      streaming = available_beta.prefered_audio(DVDPost.customer_languages[local]).find_all_by_imdb_id(imdb_id)
      streaming += available_beta.prefered_subtitle(DVDPost.customer_languages[local]).find_all_by_imdb_id(imdb_id)
    end
    streaming
  end

  def self.get_not_prefered_streaming_by_imdb_id(imdb_id, local)
    if Rails.env == "production"
      streaming = available.not_prefered(DVDPost.customer_languages[local]).find_all_by_imdb_id(imdb_id)
    else
      streaming = available_beta.not_prefered(DVDPost.customer_languages[local]).find_all_by_imdb_id(imdb_id)
    end
    streaming
  end

  def self.source
    source = OrderedHash.new
    source.push(:softlayer, 'SOFTLAYER')
    source.push(:alphanetworks, 'ALPHANETWORKS')
    source
  end

  def generate_code(code, uniq)
    if code == Digest::MD5.hexdigest("#{uniq}_#{filename}_#{imdb_id}_supernova")
      return StreamingCode.create(:name => code, :white_label => 1, :activation_group_id => 183, :expiration_at => 3.days.from_now)
    else
      nil
    end
  end
end