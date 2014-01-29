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
  alias_attribute :promo_type,                   :activation_discount_code_type
  alias_attribute :promo_id,                     :activation_discount_code_id
  alias_attribute :nb_recurring,                 :customers_abo_discount_recurring_to_date
  alias_attribute :payment_method, :customers_abo_payment_method

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
  belongs_to :address, :foreign_key => :customers_id, :primary_key => :customers_id, :conditions => {:address_book_id => '#{address_id}'} # Nasty hack for composite keys: http://gem-session.com/2010/03/using-dynamic-has_many-conditions-to-save-nested-forms-within-a-scope
  #has_one :address
  #has_many :address_books, :foreign_key => :customers_id
  belongs_to :subscription_payment_method, :foreign_key => :customers_abo_payment_method
  belongs_to :discount, :foreign_key => :activation_discount_code_id
  belongs_to :activation, :foreign_key => :activation_discount_code_id

  belongs_to :product_abo, :foreign_key => :customers_abo_type
  belongs_to :product, :foreign_key => :customers_abo_type
  belongs_to :product_next_abo, :class_name => 'ProductAbo', :foreign_key => :customers_next_abo_type
  belongs_to :product_next, :class_name => 'Product', :foreign_key => :customers_next_abo_type
  
  has_one :subscription, :foreign_key => :customerid, :conditions => {:action => [1, 6, 8]}, :order => 'date DESC'
  has_one :beta_test
  has_one :cable_order
  has_one :customer_attribute
  has_one :customers_svod
  has_one :customers_edd, :foreign_key => :customers_id
  has_many :wishlist_items, :foreign_key => :customers_id
  has_many :wishlist_products, :through => :wishlist_items, :source => :product
  has_many :assigned_items, :foreign_key => :customers_id
  has_many :assigned_products, :through => :assigned_items, :source => :product
  has_many :orders, :foreign_key => :customers_id
  has_many :ratings, :foreign_key => :customers_id
  has_many :rated_products, :through => :ratings, :source => :product, :uniq => true
  has_many :rated_products_imdb, :through => :ratings, :source => :product_imdb, :uniq => true
  has_many :reviews, :foreign_key => :customers_id
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
  has_many :suspensions
  
  has_many :customer_abo_process_stats, :foreign_key => :customers_id
  has_many :credit_histories, :foreign_key => :customers_id
  has_many :highlight_customers
  has_many :vod_wishlists
  has_many :vod_wishlists_histories
  has_many :shopping_carts, :foreign_key => :customers_id
  has_many :shopping_products, :through => :shopping_carts, :source => :product, :order => 'shopping_cart_id desc'
  has_many :shopping_orders, :foreign_key => :customers_id
  accepts_nested_attributes_for :address, :allow_destroy => true
  
  has_and_belongs_to_many :seen_products, :class_name => 'Product', :join_table => :products_seen, :uniq => true
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
      list = tokens.collect(&:imdb_id).join(',')
      vod_seen = !list.empty? ? Product.group_by_imdb.adult_available.by_imdb_ids([list]) : nil
    else
      seen = seen_products.normal_available
      list = tokens.collect(&:imdb_id).join(',')
      vod_seen = !list.empty? ? Product.group_by_imdb.normal_available.by_imdb_ids([list]) : nil
    end
    return_product = return_products(kind)
    tokens = get_all_tokens(kind, :old)
    rated = rated_products
    p = vod_seen ?  return_product + vod_seen + seen - rated :  return_product + seen - rated
   
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
    if product.imdb_id > 0
      rated_products.exists?(:imdb_id => product.imdb_id)
    else
      rated_products.exists?(product)
    end
  end

  def active?
    (abo_active? && suspension_status == 0)
  end

  def payment_suspended?
    suspension_status == 2
  end

  def holidays_suspended?
    suspension_status == 1
  end

  def suspended_notification
    if payment_suspended?
      case subscription_payment_method.to_param.to_i
      when DVDPost.payment_methods[:credit_card]
        I18n.t('customer.cc_paymet_alert')
      when DVDPost.payment_methods[:domicilation]
        I18n.t('customer.domiciliation_paymet_alert')
      else
        I18n.t('customer.other_paymet_alert')
      end
    else
      I18n.t('customer.holidays_suspended', :date => suspensions.holidays.last.date_end.strftime('%d/%m/%Y'))
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
      #recommendation_ids = DVDPost.home_page_recommendations_new(self.to_param, options[:kind])
      data = DVDPost.home_page_recommendations(self.to_param, I18n.locale)
      recommendation_ids = data[:dvd_id]
      response_id = data[:response_id]
      url = data[:url]
      results = if recommendation_ids
        hidden_ids = (rated_products + seen_products + wishlist_products + uninterested_products).uniq.collect(&:id)
        result_ids = recommendation_ids - hidden_ids
        #result_ids = recommendation_ids
        filter.update_attributes(:recommended_ids => result_ids)
        options.merge!(:subtitles => [2]) if I18n.locale == :nl
        options.merge!(:audio => [1]) if I18n.locale == :fr
        {:recommendation => Product.filter(filter, options.merge(:view_mode => :recommended)), :response_id => response_id}
      else
        []
      end
    rescue => e
      logger.error("Failed to retrieve recommendations: #{e.message}")
      {:recommendation => false, :response_id => false}
    end
  end

  def self.send_evidence(type, product_id, customer, request, params = nil , args = nil)
    begin
      ip = request.remote_ip
      product_id = product_id.to_s.gsub(/-.*/,'')
      if params[:response_id]
        params[:responseid] = params[:response_id]
        params.delete :response_id
      end
      url = DVDPost.send_evidence_recommendations(type, product_id, customer, ip, params, args)
      unless @bot
        message = ""
        message += " user #{customer.id}" if customer
        message += " url #{url}"
        message += " date #{Time.now.strftime("%Y-%m-%d %H:%M") }"
        message += " params #{params.inspect}"
        message += " request #{request.host}#{request.fullpath}"
        message += " referer #{request.referer}" if request.referer
        message += " user agent #{request.env['HTTP_USER_AGENT']}\n\r" if request.env['HTTP_USER_AGENT']
        target  = "log/check_thefilter.log"
        File.open(target, "a+") do |f|
          f.write(message)
        end
      end
    rescue => e
      logger.error("Failed to send evidence: #{e.message}")
    end
  end

  def popular(filter, options={})
    #options.merge!(:subtitles => [2]) if I18n.locale == :nl
    #options.merge!(:audio => [1]) if I18n.locale == :fr
    popular = HighlightProduct.day(0).by_kind('best').by_language(DVDPost.product_languages[I18n.locale]).ordered.find(:all, :include => :product).paginate(:per_page => 50, :page => 1)
    hidden_products = (rated_products + seen_products + wishlist_products + uninterested_products)
    pop = popular - hidden_products
  end

  def streaming(filter, options={})
    popular_vod = Product.filter(filter, options.merge(:view_mode => :streaming, :sort => 'token', :not_soon => 1))
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
    (credits == 0 || (new_price? && customers_abo_dvd_remain == 0 && customers_abo_dvd_credit <= 3 && customer_attribute.only_vod == false)) && suspension_status == 0 && subscription_type && subscription_type.credits > 0 && subscription_expiration_date && subscription_expiration_date.to_date != Time.now.to_date && abo_active?
  end

  def new_price?
    subscription_type.qty_dvd_max >= 0 if subscription_type
  end
  
  def svod?
    subscription_type.credits == 10000 if subscription_type
  end

  def next_new_price?
    next_subscription_type.qty_dvd_max >= 0 if subscription_type
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

  def init_credits(subscription, action)
    credit_paid = subscription.credits
    dvd_remain = subscription.qty_dvd_max
    Customer.transaction do
      begin
        self.update_attribute(:credits, credit_paid)
        self.update_attribute(:customers_abo_dvd_remain, dvd_remain)
        date_added = 2.hours.from_now.localtime.to_s(:db)
        history = CreditHistory.create( :customers_id => to_param.to_i, :credit_paid => 0, :credit_free => 0, :user_modified => 55, :credit_action_id => action, :date_added => date_added, :quantity_paid => credit_paid, :abo_type => subscription.to_param)
       rescue ActiveRecord::StatementInvalid 
         notify_credit_hoptoad('init',action,credit_paid)
         raise ActiveRecord::Rollback
       end
    end
    return true
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
        if new_price?
          self.update_attribute(:credits, (self.credits + quantity))
          self.update_attribute(:customers_abo_dvd_remain, (self.customers_abo_dvd_remain + quantity))
        else
          self.update_attribute(:credits, (self.credits + quantity))
        end
        date_added = 2.hours.from_now.localtime.to_s(:db)
        history = CreditHistory.create( :customers_id => to_param.to_i, :credit_paid => credit_paid, :credit_free => credit_free, :user_modified => 55, :credit_action_id => action, :date_added => date_added, :quantity_free => quantity, :abo_type => abo_type_id)
       rescue ActiveRecord::StatementInvalid 
         notify_credit_hoptoad('add',action,quantity)
         raise ActiveRecord::Rollback
       end
    end
    return true
  end

  def insert_credits(credits, dvd_remain, action)
    credit_history = self.get_credits()
    if new_price? && credit_history
      credit_free = credit_history.credit_free + credit_history.quantity_free
    else
      credit_free = 0
    end
    if new_price? && credit_history
      credit_paid = credit_history.credit_paid + credit_history.quantity_paid
    else
      credit_paid = 0
    end
    Customer.transaction do
      begin
        if new_price?
          self.update_attribute(:credits => credits)
          self.update_attribute(:customers_abo_dvd_remain => dvd_remain)
        else
          credit = self.update_attribute(:credits, (self.credits + credits))
        end
        date_added = 2.hours.from_now.localtime.to_s(:db)
        history = CreditHistory.create( :customers_id => to_param.to_i, :credit_paid => credit_paid, :credit_free => credit_free, :user_modified => 55, :credit_action_id => action, :date_added => date_added, :quantity_free => credits, :abo_type => abo_type_id)
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
          new_qty = (self.credits - quantity)
          credit = self.update_attribute(:credits, new_qty)
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

  def create_token(imdb_id, product, current_ip, streaming_product_id, kind, source = 7)
    file = StreamingProduct.find(streaming_product_id)
    if StreamingProductsFree.by_imdb_id(imdb_id).available.count > 0 || file.is_ppv
        begin
          token_string = DVDPost.generate_token_from_alpha(file.filename, kind, false)
        rescue => e
          token_string = false
        end
        
        if token_string
          token = file.is_ppv ? Token.create(:customer_id => id, :imdb_id => imdb_id, :token => token_string, :is_ppv => true, :ppv_price => file.ppv_price, :source_id => source, :country => file.country, :credits => file.credits, :kind => 'PPV') : Token.create(:customer_id => id, :imdb_id => imdb_id, :token => token_string, :source_id => source, :country => file.country, :credits => file.credits)
          if token.id.blank?
            return {:token => nil, :error => Token.error[:query_rollback]}
          else
            return {:token => token, :error => nil}
          end
        else
          return {:token => nil, :error => Token.error[:generation_token_failed]}
        end
    end
    
    if credits >= file.credits || (product.adult? && svod_adult > 0 && file.studio_id == 147)
      abo_process = AboProcess.today.last
      if abo_process 
        customer_abo_process = customer_abo_process_stats.find_by_aboprocess_id(abo_process.to_param)
      end
      
      if !abo_process || (customer_abo_process || abo_process.finished?)
        begin
          token_string = DVDPost.generate_token_from_alpha(file.filename, kind, false)
        rescue => e
          token_string = false
        end
        if token_string
          kind = (svod_adult > 0 && file.studio_id == 147) ? "SVOD_ADULT" : "NORMAL"
          
          Token.transaction do
            token = Token.create(          
              :customer_id => id,          
              :imdb_id     => imdb_id,          
              :token       => token_string,
              :source_id   => source,
              :country     => file.country,
              :credits     => file.credits,
              :kind        => kind
            )
            result_credit = (product.adult? && svod_adult > 0 && file.studio_id == 147) ? true : remove_credit(file.credits, 12)
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
        return {:token => nil, :error => Token.error[:abo_process_error]}
      end
    else
      return {:token => nil, :error => Token.error[:not_enough_credit]}
    end
  end

  def get_token(imdb_id)
    tokens.recent(2.week.ago.localtime, Time.now).find_all_by_imdb_id(imdb_id).last
  end

  def get_all_tokens_id(kind = nil, imdb_id = 0)
    if imdb_id > 0
      tokens.available(DVDPost.hours[kind].hours.ago.localtime, Time.now).find_all_by_imdb_id(imdb_id).collect(&:imdb_id)
    else
      tokens.available(DVDPost.hours[kind].hours.ago.localtime, Time.now).collect(&:imdb_id)
    end  
  end

  def get_all_tokens(kind = nil, type = nil, page = 1)
    if type == :old
      if kind == :adult
        tokens.expired(DVDPost.hours[:adult].hours.ago.localtime).ordered_old.all(:joins => :products, :group => :imdb_id,  :conditions => {:products => {:products_type => DVDPost.product_kinds[:adult]}}).paginate(:per_page => 20, :page => page)
      else kind == :normal
        tokens.expired(DVDPost.hours[:normal].hours.ago.localtime).ordered_old.all(:joins => :products, :group => :imdb_id, :conditions => {:products => {:products_type => DVDPost.product_kinds[:normal]}}).paginate(:per_page => 24, :page => page)
      end
    else
      if kind == :adult
        tokens.available(DVDPost.hours[:adult].hours.ago.localtime, Time.now).ordered.all(:joins => {:streaming_products, :products}, :group => :imdb_id, :conditions => { :streaming_products => { :available => 1 }, :products => {:products_type => DVDPost.product_kinds[:adult]}})
      elsif kind == :normal
        tokens.available(DVDPost.hours[:normal].hours.ago.localtime, Time.now).ordered.all(:joins => {:streaming_products, :products}, :group => :imdb_id, :conditions => { :streaming_products => { :available => 1 }, :products => {:products_type => DVDPost.product_kinds[:normal]}})
      else
        tokens.available(2.days.ago.localtime, Time.now).ordered.all(:joins => :streaming_products, :group => :imdb_id, :conditions => { :streaming_products => { :available => 1 }})
    end
    end
  end
  
  def remove_product_from_wishlist(imdb_id, current_ip)
    all = Product.find_all_by_imdb_id(imdb_id)
    wl = wishlist_items.find_all_by_product_id(all)
    unless wl.blank?
      wl.each do |item|
        item.destroy()
        Customer.send_evidence('RemoveFromWishlist', item.to_param, self, current_ip)   
      end
    end
    if vod_wishlists && vod_wishlists.find_by_imdb_id(imdb_id)
      vod = vod_wishlists.find_by_imdb_id(imdb_id)
      vod_wishlists_histories.create(:imdb_id => vod.imdb_id, :source_id => vod.source_id, :added_at => vod.created_at)
      vod.destroy() 
    end
  end
  
  def recondutction_ealier?
    !actions.reconduction_ealier.recent.blank?
  end

  def reconduction_now
    update_attribute(:auto_stop, 0)
    update_attribute(:subscription_expiration_date, Time.now().localtime.to_s(:db))
    customer_attribute.update_attribute(:credits_already_recieved, 1)
    abo_history(Subscription.action[:reconduction_ealier])
    
    manage_credits(next_subscription_type, 15)
  end

  def manage_credits(subscription, action)
    if subscription.qty_dvd_max != -1
      init_credits(subscription, action)
    else
      add_credit(subscription.credits, action)
    end
  end

  def abo_history(action, new_abo_type = 0)
    Subscription.create(:customer_id => self.to_param, :Action => action, :Date => Time.now().to_s(:db), :product_id => (new_abo_type.to_i > 0 ? new_abo_type : self.abo_type_id), :site => 1, :payment_method => subscription_payment_method.name.upcase)
  end

  def is_freetest?
    if abo_active == 1 && actions.reconduction.length > 0 && actions.reconduction.last.action == 7
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

  def display_vod(status)
    build_customer_attribute unless customer_attribute
    customer_attribute.update_attribute(:display_vod, status)
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
  
  def dvd_max_per_month
    if subscription_type
      subscription_type.qty_dvd_max
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
  
  def next_dvd_per_month
    if next_subscription_type
      next_subscription_type.qty_dvd_max
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

  def get_list_abo(force_group = nil)
    if force_group
      group = force_group
    else
      if self.new_price?
        group = 6
      else
        group = 1
      end
    end
    ProductAbo.get_list(group)
  end

  def get_next_list_abo
    if self.next_new_price?
      group = 6
    else
      group = 1
    end
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
  
  def promo_price(promo = {}, abo_next = false)
    abo_price = ProductAbo.find(abo_type_id).product.price.to_f
    type = promo[:type] ? promo[:type] : activation_discount_code_type
    if type == 'A'
      price = 0
    elsif type == 'D'
      disc = promo[:discount_id] && promo[:discount_id] > 0 ? Discount.find(promo[:discount_id]) : discount
      
      case disc.type
        #total = price - X%
        when 1
          price = (abo_price - (disc.value / 100 * abo_price)).round(2)
        # tot = X € 
        when 2
          price = disc.value
        # tot = price - X€
        when 3
          price = abo_price - disc.value
      end
    else
      price = abo_price  
    end
    price.to_f
  end

  def promo_date
    type = activation_discount_code_type
    if type == 'A'
      activation.duration
    elsif type == 'D'
      discount.duration
    end
  end

  def token_available?(product)
    tokens_products.exists?(product.imdb_id)
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
      Airbrake.notify(:error_message => "customer dont abo abo_type : #{to_param}", :backtrace => $@, :environment_name => ENV['RAILS_ENV'])
    rescue => e
      logger.error("customer dont abo abo_type : #{to_param}")
      logger.error(e.backtrace)
    end
  end
  
  def notify_credit_hoptoad(action, action_type, quantity)
    begin
      Airbrake.notify(:error_message => "customer have a problem with credit customer_id : #{to_param} action: #{action} action type: #{action_type} quantity: #{quantity}", :backtrace => $@, :environment_name => ENV['RAILS_ENV'])
    rescue => e
      logger.error("customer have a problem with credit customer_id : #{to_param} action: #{action} action type: #{action_type} quantity: #{quantity}")
      logger.error(e.backtrace)
    end
  end
end
