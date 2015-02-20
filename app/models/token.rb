class Token < ActiveRecord::Base
  belongs_to :customer, :primary_key => :customers_id
  has_many :streaming_products, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :streaming_products_free, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :products, :foreign_key => :imdb_id, :primary_key => :imdb_id
  belongs_to :product, :foreign_key => :imdb_id, :primary_key => :imdb_id
  

  after_create :generate_token

  validates_presence_of :imdb_id

  named_scope :available, lambda {|from, to| {:conditions => {:updated_at => from..to}}}
  named_scope :expired, lambda {|to| {:conditions => ["updated_at < ?", to]}}
  named_scope :is_public, :conditions => {:customer_id => nil}

  named_scope :recent, lambda {|from, to| {:conditions => {:updated_at=> from..to}}}
  named_scope :by_imdb_id, lambda {|imdb_id| {:conditions => {:imdb_id=> imdb_id}}}
  
  named_scope :ordered, :order => 'updated_at asc'
  named_scope :ordered_old, :order => 'updated_at desc'

  def self.regen
    Token.recent(2.days.ago.localtime, Time.now).all(:include => :streaming_products, :conditions => {:streaming_products => {:studio_id => 750}}).each do |token|
      filename = token.streaming_products.alpha.first.filename
      puts filename
      token_string = DVDPost.generate_token_from_alpha(filename, :normal, true)
      puts token_string
      token.update_attribute(:token, token_string)
    end
  end
  
  def self.validate(token_param, filename, ip)
    
    token = self.available(2.days.ago.localtime..Time.now).find_by_token(token_param)
    if token
      filename = "mp4:#{filename}"
      filename_select = StreamingProduct.by_filename(filename).all(:include => :tokens, :conditions => ['tokens.id = ?', token.id])
    end
    if token && !filename_select.blank?
      1
    else
      0
    end
  end

  def self.dvdpost_ip?(client_ip)
    if client_ip == DVDPost.dvdpost_ip[:internal]
      return true
    else
      DVDPost.dvdpost_ip[:external].each do |external|
        if client_ip == external
          return true
        end
      end
      return false
    end
  end
  
  def self.error
    error = OrderedHash.new
    error.push(:abo_process_error, 1)
    error.push(:not_enough_credit, 2)
    error.push(:query_rollback, 3)
    error.push(:user_suspended, 4)
    error.push(:generation_token_failed, 5)
    error.push(:customer_not_activated, 6)
    
    error
  end

  def self.status
    status = OrderedHash.new
    status.push(:ok, 1)
    status.push(:expired, 4)

    status
  end

  def expired?
    if products.first.kind == DVDPost.product_kinds[:adult]
      hours_left = DVDPost.hours[:adult]
    else
      hours_left = DVDPost.hours[:normal]
    end
    updated_at < hours_left.hours.ago.localtime
  end

  def current_status(current_ip)
    
    return Token.status[:expired] if expired?
    return Token.status[:ok]
  end
  
  def validate?(current_ip)
    token_status = current_status(current_ip)
    return token_status == Token.status[:ok] || token_status == Token.status[:ip_valid]
  end

  def self.create_token(imdb_id, product, current_ip, streaming_product_id, kind, code, source = 7)
    #to do valid code
    file = StreamingProduct.find(streaming_product_id)
    token_string = '3/i/'+ imdb_id.to_s
    if token_string
      begin
        if source.nil? || source.empty?
          source = 7
        end
        ActiveRecord::Base.connection.execute("call sp_token_insert(NULL,'#{token_string}', #{imdb_id}, '#{current_ip}', '#{file.country}', '#{code}', #{source.to_i})")
        token = Token.find_by_token(token_string)
      rescue  => e
        token_create = false
      end
      #token = Token.create(          
      #  :code => code,          
      #  :imdb_id     => imdb_id,          
      #  :token       => token_string,
      #  :source_id   => source,
      #  :country => file.country,
      #  :credits => file.credits
      #)
      if token_create == false
        return {:token => nil, :error => Token.error[:query_rollback]}
      else
        StreamingCode.find_by_name(code).update_attribute(:used_at, Time.now.localtime)
        return {:token => token, :error => nil}
      end
    else
      return {:token => nil, :error => Token.error[:generation_token_failed]}
    end
  end  

  private
  def generate_token
    if token.nil?
      update_attribute(:token, Digest::SHA1.hexdigest((created_at.to_s) + (97 * created_at.to_i).to_s))
    end
  end
end