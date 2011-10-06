class Customer < ActiveRecord::Base
  set_table_name :customers

  set_primary_key :customers_id

  attr_accessor :clear_pwd
  attr_accessor :new_email

  alias_attribute :abo_active,                   :customers_abo
  alias_attribute :last_name,                    :customers_lastname
  alias_attribute :first_name,                   :customers_firstname
  alias_attribute :credits,                      :customers_abo_dvd_credit
  alias_attribute :email,                        :customers_email_address
  alias_attribute :password,                     :customers_password
  alias_attribute :language,                     :customers_language
  alias_attribute :suspension_status,            :customers_abo_suspended
  alias_attribute :dvds_at_home_count,           :customers_abo_dvd_home_norm
  alias_attribute :dvds_at_home_adult_count,     :customers_abo_dvd_home_adult
  alias_attribute :address_id,                   :customers_default_address_id
  alias_attribute :inviation_points,             :mgm_points
  alias_attribute :credits,                      :customers_abo_dvd_credit
  alias_attribute :normal_count,                 :customers_abo_dvd_norm
  alias_attribute :adult_count,                  :customers_abo_dvd_adult
  alias_attribute :subscription_expiration_date, :customers_abo_validityto
  alias_attribute :newsletter,                   :customers_newsletter
  alias_attribute :newsletter_parnter,           :customers_newsletterpartner
  alias_attribute :phone,                        :customers_telephone
  alias_attribute :birthday,                     :customers_dob
  alias_attribute :gender,                       :customers_gender
  alias_attribute :payment_method,               :customers_abo_payment_method
  alias_attribute :abo_type_id,                  :customers_abo_type
  alias_attribute :auto_stop,                    :customers_abo_auto_stop_next_reconduction
  alias_attribute :next_abo_type_id,             :customers_next_abo_type
  alias_attribute :free_upgrade,                 :customers_locked__for_reconduction
  

  validates_length_of :first_name, :minimum => 2
  validates_length_of :last_name, :minimum => 2
  validates_format_of :phone, :with => /^(\+)?[0-9 \-\/.]+$/, :on => :update
  validates_length_of :clear_pwd_confirmation, :minimum => 5, :unless => :clear_pwd_empty?
  validates_confirmation_of :clear_pwd, :unless => :clear_pwd_empty?
  validates_format_of :customers_email_address, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
  validates_uniqueness_of :customers_email_address, :case_sensitive => false

  before_save :encrypt_password, :unless => :clear_pwd_empty?
  before_validation_on_update :email_change
  
  belongs_to :subscription_type, :foreign_key => :customers_abo_type
  belongs_to :next_subscription_type, :class_name => 'SubscriptionType', :foreign_key => :customers_next_abo_type
  belongs_to :address, :foreign_key => :customers_id, :conditions => {:address_book_id => '#{address_id}'} # Nasty hack for composite keys: http://gem-session.com/2010/03/using-dynamic-has_many-conditions-to-save-nested-forms-within-a-scope
  belongs_to :subscription_payment_method, :foreign_key => :customers_abo_payment_method
  has_one :subscription, :foreign_key => :customerid, :conditions => {:action => [1, 6, 8]}, :order => 'date DESC'
  has_one :beta_test
  has_one :cable_order
  has_one :customer_attribute
  has_many :wishlist_items, :foreign_key => :customers_id
  has_many :wishlist_products, :through => :wishlist_items, :source => :product
  has_many :assigned_items, :foreign_key => :customers_id
  has_many :assigned_products, :through => :assigned_items, :source => :product
  has_many :orders, :foreign_key => :customers_id
  has_many :ratings
  has_many :rated_products, :through => :ratings, :source => :movie, :uniq => true
  has_many :reviews
  has_many :uninteresteds, :foreign_key => :customers_id
  has_many :uninterested_products, :through => :uninteresteds, :source => :product, :uniq => true
  has_many :messages, :foreign_key => :customers_id
  has_many :tickets
  has_many :compensations, :foreign_key => :customers_id
  has_many :addresses, :foreign_key => :customers_id
  has_many :payment, :foreign_key => :customers_id
  has_many :subscriptions, :foreign_key => :customerid, :conditions => {:action => [1, 6, 8]}, :order => 'date DESC', :limit => 1
  has_many :actions, :foreign_key => :customerid, :class_name => 'Subscription'
  has_many :contests, :foreign_key => :customers_id
  has_many :sponsorships, :foreign_key => :father_id
  has_many :sponsorship_emails, :foreign_key => :customers_id
  has_many :gifts_history, :foreign_key => :customers_id
  has_many :additional_card, :foreign_key => :customers_id
  has_many :tokens
  has_many :customer_abo_process_stats, :foreign_key => :customers_id
  has_many :credit_histories, :foreign_key => :customers_id
  has_many :highlight_customers
  
  #to do
  #has_and_belongs_to_many :seen_products, :class_name => 'Product', :join_table => :product_seen, :uniq => true
  has_and_belongs_to_many :roles, :uniq => true

  def self.credit_action
    credit = OrderedHash.new
    credit.push(:vod, 1)
    credit.push(:vod_more_ip, 2)

    credit
  end

  def email_change
    if self.email != self.new_email
      self.is_email_valid = 1
    end
  end

  def clear_pwd_empty?
    clear_pwd.nil? || clear_pwd.blank?
  end

  def encrypt_password
    self.password= Digest::MD5.hexdigest(clear_pwd)
  end

  def self.find_by_email(args)
    self.find_by_customers_email_address(args)
  end

  def not_rated_products(kind)
    if kind == :adult
      seen = seen_products.adult_available
    else
      seen = seen_products.normal_available
    end
    return_product = return_products(kind)
    
    rated = rated_products
    p = seen + return_product - rated
  end

  def return_products(kind)
    o = orders.return.all(:select => 'orders_products.products_id as orders_id', :joins => :order_product)
    if kind == :adult
      Product.adult_available.find_all_by_products_id(o)
    else
      Product.normal_available.find_all_by_products_id(o)
    end
  end

  def has_rated?(product)
    rated_products.exists?(product)
  end

  def active?
    (abo_active? && suspension_status == 0)
  end

  def payment_suspended?
    suspension_status == 2
  end

  def suspended_notification
    case subscription_payment_method.to_param.to_i
    when DVDPost.payment_methods[:credit_card]
      I18n.t('customer.cc_paymet_alert')
    when DVDPost.payment_methods[:domicilation]
      I18n.t('customer.domiciliation_paymet_alert')
    else
      I18n.t('customer.other_paymet_alert')
    end
  end

  def authenticated?(provided_password)
    hash_password, salt = password.split(':')
    result = Digest::MD5.hexdigest("#{salt}#{provided_password}")
    return hash_password == result
  end

  def self.authenticate(email, password)
    return nil      unless customer = find_by_email(email)
    return customer if     customer.authenticated?(password)
  end

  def has_role?(role)
    roles.include?(role)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def recommendations(filter, options)
    begin
      # external service call can't be allowed to crash the app
      recommendation_ids = DVDPost.home_page_recommendations(self.to_param)
      results = if recommendation_ids
        hidden_ids = (rated_products + seen_products + wishlist_products + uninterested_products).uniq.collect(&:id)
        result_ids = recommendation_ids - hidden_ids
        filter.update_attributes(:recommended_ids => result_ids)
        options.merge!(:subtitles => [2]) if I18n.locale == :nl
        options.merge!(:audio => [1]) if I18n.locale == :fr
        Product.filter(filter, options.merge(:view_mode => :recommended))
      else
        []
      end
    rescue => e
      logger.error("Failed to retrieve recommendations: #{e.message}")
      false
    end
  end

  def self.send_evidence(type, product_id, customer, ip, args=nil)
    begin
      DVDPost.send_evidence_recommendations(type, product_id, customer, ip, args) 
    rescue => e
      logger.error("Failed to send evidence: #{e.message}")
    end
  end

  def popular(filter, options={})
    options.merge!(:subtitles => [2]) if I18n.locale == :nl
    options.merge!(:audio => [1]) if I18n.locale == :fr
    popular = Product.filter(filter, options.merge(:view_mode => :popular))
    hidden_products = (rated_products + seen_products + wishlist_products + uninterested_products)
    pop = popular - hidden_products
  end

  def streaming(filter, options={})
    popular_vod = Product.filter(filter, options.merge(:view_mode => :streaming, :sort => 'token'))
    hidden_products = (rated_products + seen_products + wishlist_products + uninterested_products)
    pop = popular_vod - hidden_products
  end

  def update_dvd_at_home!(operator, product)
    attribute = if product.kind == DVDPost.product_kinds[:adult]
      :customers_abo_dvd_home_adult
    else
      :customers_abo_dvd_home_norm
    end
    operator == :increment ? increment!(attribute) : decrement!(attribute)
  end

  def newsletter!(type,value)
    if type == 'newsletter_parnter'
      update_attribute(:newsletter_parnter, value)
    else
      update_attribute(:newsletter, value)
    end
  end

  def rotation_dvd!(type,value)
    if type == 'adult'
      if normal_count > 0
        update_attribute(:adult_count, (adult_count + value))
        update_attribute(:normal_count, (normal_count - value))
        abo_history(Subscription.action[:add_rotation_adult])
      end
    else
      if adult_count > 0
        update_attribute(:normal_count, (normal_count + value))
        update_attribute(:adult_count, (adult_count - value))
        abo_history(Subscription.action[:add_rotation_normal])
      end
    end
  end

  def credit_empty?
    credits == 0 && suspension_status == 0 && subscription_type && subscription_type.credits > 0 && subscription_expiration_date && subscription_expiration_date.to_date != Time.now.to_date
  end

  def suspended?
    suspension_status != 0
  end

  def locale
    loc = DVDPost.customer_languages.invert[language]
    loc.to_sym if loc
  end

  def locale=(new_locale)
    language_id = DVDPost.customer_languages[new_locale] || DVDPost.customer_languages[:fr]
    update_attribute(:customers_language, language_id)
  end

  def update_locale(new_locale)
    new_locale ||= locale
    update_attribute(:customers_language, (DVDPost.customer_languages[new_locale] || :fr))
    locale = new_locale.blank? ? :fr : new_locale
  end

  def get_credits()
    credit_histories.last
  end

  def add_credit(quantity, action)
    credit_history = self.get_credits()
    if credit_history
      credit_free = credit_history.credit_free + credit_history.quantity_free
    else
      credit_free = 0
    end
    
    if credit_history
      credit_paid = credit_history.credit_paid + credit_history.quantity_paid
    else
      credit_paid = 0
    end
    Customer.transaction do
      begin
        credit = self.update_attribute(:credits, (self.credits + quantity))
        date_added = 2.hours.from_now.localtime.to_s(:db)
        history = CreditHistory.create( :customers_id => to_param.to_i, :credit_paid => credit_paid, :credit_free => credit_free, :user_modified => 55, :credit_action_id => action, :date_added => date_added, :quantity_free => quantity, :abo_type => abo_type_id)
       rescue ActiveRecord::StatementInvalid 
         notify_credit_hoptoad('add',action,quantity)
         raise ActiveRecord::Rollback
       end
    end
    return true
  end
  
  def remove_credit(quantity, action)
    credit_history = self.get_credits()
    if credit_history
      credit_free = credit_history.credit_free + credit_history.quantity_free
    else
      credit_free = 0
    end
    if credit_history
      credit_paid = credit_history.credit_paid + credit_history.quantity_paid
    else
      credit_paid = 0
    end
    status = true
    if credit_free >= quantity
      qt_free = quantity
      qt_paid = 0
    elsif credit_free + credits >= quantity
      qt_paid = quantity - credit_free
      qt_free = credit_free
    elsif credits >= quantity 
      qt_free = 0
      qt_paid = quantity
    else
      status = false
    end
    if status == true
      Customer.transaction do
        begin
          credit = self.update_attribute(:credits, (self.credits - quantity))
          history = CreditHistory.create( :customers_id => to_param.to_i, :credit_paid => credit_paid, :credit_free => credit_free, :user_modified => 55, :credit_action_id => action, :date_added => Time.now().localtime.to_s(:db), :quantity_free => (- qt_free), :quantity_paid => (- qt_paid), :abo_type => abo_type_id)
        rescue ActiveRecord::StatementInvalid 
           notify_credit_hoptoad('remove',action,quantity)
           raise ActiveRecord::Rollback
        end
      end 
      true 
    else
      false  
    end
  end

  def create_token(imdb_id, product, current_ip, streaming_product_id)
    file = StreamingProduct.find(streaming_product_id)
    if StreamingProductsFree.by_imdb_id(imdb_id).available.count > 0 #|| super_user?
      if file.source == StreamingProduct.source[:alphanetworks]
        token_string = DVDPost.generate_token_from_alpha(file.filename)
        if token_string
          token = Token.create(          
            :customer_id => id,          
            :imdb_id     => imdb_id,          
            :token       => token_string        
          )
          if token.id.blank?
            return {:token => nil, :error => Token.error[:query_rollback]}
          else
            return {:token => token, :error => nil}
          end
        else
          return {:token => nil, :error => Token.error[:generation_token_failed]}
        end
      else
        Token.transaction do
          token = Token.create(
            :customer_id => id,
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
    if credits >= file.credits
      abo_process = AboProcess.today.last
      if abo_process 
        customer_abo_process = customer_abo_process_stats.find_by_aboprocess_id(abo_process.to_param)
      end
      
      if !abo_process || (customer_abo_process || abo_process.finished?)
        
        if file.source == StreamingProduct.source[:alphanetworks]
          token_string = DVDPost.generate_token_from_alpha(file.filename)
          if token_string
            Token.transaction do
              token = Token.create(          
                :customer_id => id,          
                :imdb_id     => imdb_id,          
                :token       => token_string        
              )
              result_credit = remove_credit(file.credits, 12)
              if token.id.blank? || result_credit == false
                error = Token.error[:query_rollback]
                raise ActiveRecord::Rollback
                return {:token => nil, :error => Token.error[:query_rollback]}
              end
              {:token => token, :error => nil}
            end
          else
            return {:token => nil, :error => Token.error[:generation_token_failed]}
          end
        else
          Token.transaction do
            token = Token.create(
              :customer_id => id,
              :imdb_id     => imdb_id
            )
            token_ip = TokenIp.create(
              :token_id => token.id,
              :ip => current_ip
            )
            result_credit = remove_credit(file.credits, 12)
            if token.id.blank? || token_ip.id.blank? || result_credit == false
              error = Token.error[:query_rollback]
              raise ActiveRecord::Rollback
              return {:token => nil, :error => Token.error[:query_rollback]}
            end
            {:token => token, :error => nil}
          end
        end
      else
        return {:token => nil, :error => Token.error[:abo_process_error]}
      end
    else
      return {:token => nil, :error => Token.error[:not_enough_credit]}
    end
  end

  def create_token_ip(token, current_ip)
    token_ip = TokenIp.create(
      :token_id => token.id,
      :ip => current_ip
    )
    if token_ip.id.blank?
      error = Token.error[:query_rollback]
    else
      true
    end 
  end

  def create_more_ip(token, current_ip)
    if StreamingProductsFree.by_imdb_id(token.imdb_id).available.count > 0
      Token.transaction do
        more_ip = token.update_attributes(:count_ip => (token.count_ip + 2), :updated_at => Time.now.to_s(:db))
        token_ip = TokenIp.create(:token_id => token.id,:ip => current_ip)
        if more_ip == false || token_ip.id.blank? 
          raise ActiveRecord::Rollback
          return {:token => nil, :error => Token.error[:query_rollback]}
        else
          return {:token => token, :error => nil}
        end
      end
    else
      if credits >= token.streaming_products.first.credits
        abo_process = AboProcess.today.last
        if abo_process 
          customer_abo_process = customer_abo_process_stats.find_by_aboprocess_id(abo_process.to_param)
        end
        if !abo_process || (customer_abo_process || abo_process.finished?)
          Token.transaction do
            more_ip = token.update_attributes(:count_ip => (token.count_ip + 2), :updated_at => Time.now.to_s(:db))
            result_history = remove_credit(token.streaming_products.first.credits,13)
            token_ip = TokenIp.create(:token_id => token.id,:ip => current_ip)
            if more_ip == false || token_ip.id.blank? || result_history == false
              raise ActiveRecord::Rollback
              return {:token => nil, :error => Token.error[:query_rollback]}
            else
              return {:token => token, :error => nil}
            end
          end
        else
          return {:token => nil, :error => Token.error[:abo_process_error]}
        end
      else
        return {:token => nil, :error => Token.error[:not_enough_credit]}
      end
    end
  end

  def get_token(imdb_id)
    tokens.recent(2.week.ago.localtime, Time.now).find_all_by_imdb_id(imdb_id).last
  end
  
  def get_all_tokens
    tokens.available(2.days.ago.localtime, Time.now).ordered.all(:joins => :streaming_products, :group => :imdb_id, :conditions => { :streaming_products => { :available => 1 }})
  end
  
  def remove_product_from_wishlist(imdb_id, current_ip)
    #all = Movie.find_all_by_imdb_id(imdb_id)
    #wl = wishlist_items.find_all_by_product_id(all)
    #unless wl.blank?
    #  wl.each do |item|
    #    item.destroy()
    #    Customer.send_evidence('RemoveFromWishlist', item.to_param, self, current_ip)   
    #  end
    #end
  end
  
  def recondutction_ealier?
    !actions.reconduction_ealier.recent.blank?
  end

  def reconduction_now
    update_attributes(:auto_stop => 0, :subscription_expiration_date => Time.now().localtime.to_s(:db), :credits => (credits + next_subscription_type.credits))
    customer_attribute.update_attribute(:credits_already_recieved, 1)
    abo_history(Subscription.action[:reconduction_ealier])
  end
  
  def abo_history(action, new_abo_type = 0)
    Subscription.create(:customer_id => self.to_param, :Action => action, :Date => Time.now().localtime.to_s(:db), :product_id => (new_abo_type.to_i > 0 ? new_abo_type : self.abo_type_id), :site => 1, :payment_method => subscription_payment_method.name.upcase)
  end

  def is_freetest?
    if actions.reconduction.length > 0 && actions.reconduction.last.action == 7
      false
    else
      true
    end
  end

  def nederlands?
    address.country_id == 150
  end

  def actived?
    abo_active == 1 
  end

  def inducator_close(status)
    build_customer_attribute unless customer_attribute
    customer_attribute.update_attribute(:list_indicator_close, status)
  end

  def bluray_owner(status)
    build_customer_attribute unless customer_attribute
    customer_attribute.update_attribute(:bluray_owner, status)
  end

  def last_login(kind)
    build_customer_attribute unless customer_attribute
    if kind == :normal
      init = (customer_attribute && customer_attribute.number_of_logins ? customer_attribute.number_of_logins : 0)
      customer_attribute.update_attributes(:number_of_logins  =>  (init + 1), :last_login_at => Time.now.to_s(:db) )
    else
      init = (customer_attribute && customer_attribute.number_of_logins_x ? customer_attribute.number_of_logins_x : 0)
      customer_attribute.update_attributes(:number_of_logins_x  =>  (init + 1), :last_login_at => Time.now.to_s(:db) )
    end
  end

  def credit_per_month
    if subscription_type
      subscription_type.credits
    else
      notify_hoptoad()
      '0'
    end
  end
  
  def price_per_month 
    if subscription_type
      subscription_type.product.price
    else
      notify_hoptoad()
      '0'
    end
  end

  def next_credit_per_month
    if next_subscription_type
      next_subscription_type.credits
    else
      notify_hoptoad()
      '0'
    end
  end
  
  def next_price_per_month 
    if next_subscription_type
      next_subscription_type.product.price
    else
      notify_hoptoad()
      '0'
    end
  end

  def get_list_abo
    group = 1
    ProductAbo.get_list(group)
  end

  def super_user?
    DVDPost.dvdpost_super_user.each do |super_id| 
      if to_param.to_i == super_id.to_i
        return true
      end
    end
    return false
  end

  def image(type = :accepted)
    if type == :accepted
      File.join('avatars', 'accepted', "#{to_param}.jpg")
    else
      File.join('avatars', 'waiting', "#{to_param}.jpg")
    end 
  end
  private
  def convert_created_at
    begin
      self.created_at = Date.civil(self.year.to_i, self.month.to_i, self.day.to_i)
    rescue ArgumentError
      false
    end
  end

  def validate_created_at
    errors.add("Created at date", "is invalid.") unless convert_created_at
  end

  def notify_hoptoad()
    begin
      HoptoadNotifier.notify(:error_message => "customer dont abo abo_type : #{to_param}")
    rescue => e
      logger.error("customer dont abo abo_type : #{to_param}")
      logger.error(e.backtrace)
    end
  end
  
  def notify_credit_hoptoad(action, action_type, quantity)
    begin
      HoptoadNotifier.notify(:error_message => "customer have a problem with credit customer_id : #{to_param} action: #{action} action type: #{action_type} quantity: #{quantity}")
    rescue => e
      logger.error("customer have a problem with credit customer_id : #{to_param} action: #{action} action type: #{action_type} quantity: #{quantity}")
      logger.error(e.backtrace)
    end
  end
end