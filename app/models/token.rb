class Token < ActiveRecord::Base
  belongs_to :customer, :primary_key => :customers_id
  has_many :streaming_products, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :streaming_products_free, :primary_key => :imdb_id, :foreign_key => :imdb_id
  has_many :token_ips
  has_many :products, :foreign_key => :imdb_id, :primary_key => :imdb_id

  after_create :generate_token

  validates_presence_of :imdb_id

  named_scope :available, lambda {|from, to| {:conditions => {:updated_at => from..to}}}

  named_scope :recent, lambda {|from, to| {:conditions => {:updated_at=> from..to}}}
  named_scope :by_imdb_id, lambda {|imdb_id| {:conditions => {:imdb_id=> imdb_id}}}
  
  named_scope :ordered, :order => 'updated_at asc'
  
  def self.validate(token_param, filename, ip)
    
    token = self.available(2.days.ago.localtime..Time.now).find_by_token(token_param)
    if token
      filename = "mp4:#{filename}"
      filename_select = StreamingProduct.by_filename(filename).all(:include => :tokens, :conditions => ['tokens.id = ?', token.id])
      token_ips = token.token_ips
      select = token_ips.find_by_ip(ip)
    end
    if token && select && !filename_select.blank?
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
    status.push(:ip_valid, 2)
    status.push(:ip_invalid, 3)
    status.push(:expired, 4)

    status
  end

  def expired?
    updated_at < 2.days.ago.localtime
  end

  def current_status(current_ip)
    
    return Token.status[:expired] if expired?
    
    current_ips = token_ips
    return Token.status[:ok] if !current_ips.find_by_ip(current_ip).nil? || streaming_products.alpha.count > 0
    return Token.status[:ip_valid] if current_ips.count < count_ip 
    return Token.status[:ip_invalid]
  end
  
  def validate?(current_ip)
    token_status = current_status(current_ip)
    return token_status == Token.status[:ok] || token_status == Token.status[:ip_valid]
  end

  def self.create_token(imdb_id, product, current_ip, streaming_product_id, code)
    #to do valid code
    file = StreamingProduct.find(streaming_product_id)
      if file.source == StreamingProduct.source[:alphanetworks]
        token_string = DVDPost.generate_token_from_alpha(file.filename)
        if token_string
          token = Token.create(          
            :code => code,          
            :imdb_id     => imdb_id,          
            :token       => token_string        
          )
          if token.id.blank?
            return {:token => nil, :error => Token.error[:query_rollback]}
          else
            StreamingCode.find_by_name(code).update_attribute(:used_at, Time.now.localtime)
            return {:token => token, :error => nil}
          end
        else
          return {:token => nil, :error => Token.error[:generation_token_failed]}
        end
      else
        Token.transaction do
          token = Token.create(
            :code => code,
            :imdb_id     => imdb_id
          )
          token_ip = TokenIp.create(
            :token_id => token.id,
            :ip => current_ip
          )
          if token.id.blank? || token_ip.id.blank? 
            error = Token.error[:query_rollback]
            raise ActiveRecord::Rollback
            return {:token => nil, :error => Token.error[:query_rollback]}
          end
          return {:token => token, :error => nil}
        end
      end
  end  

  private
  def generate_token
    if token.nil?
      update_attribute(:token, Digest::SHA1.hexdigest((created_at.to_s) + (97 * created_at.to_i).to_s))
    end
  end
end