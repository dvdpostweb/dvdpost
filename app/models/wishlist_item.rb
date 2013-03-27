class WishlistItem < ActiveRecord::Base
  set_table_name :wishlist

  set_primary_key :wl_id

  alias_attribute :created_at, :date_added
  alias_attribute :type, :wishlist_type

  belongs_to :customer, :foreign_key => :customers_id
  belongs_to :product, :foreign_key => :product_id
  belongs_to :wishlist_source

  before_create :set_created_at
  before_validation :set_defaults

  validates_presence_of :product
  validates_presence_of :customer
  validates_inclusion_of :type, :in => DVDPost.product_kinds.values
  validates_uniqueness_of :product_id, :scope => [:customers_id, :product_id]

  named_scope :ordered, :order => 'priority ASC, products_name asc, imdb_id, products.products_id'
  named_scope :ordered_by_id, :order => 'wl_id desc'
  
  named_scope :by_kind, lambda {|kind| {:conditions => {:wishlist_type => DVDPost.product_kinds[kind]}}}
  named_scope :available, :conditions => ['products_status != ?', '-1']
  named_scope :current, :conditions => ['products.products_next = ? and products.products_availability != ?', '0', '-1']
  named_scope :future, :conditions => ['products.products_next = ? and products.products_availability != ?', '1', '-1']
  named_scope :not_available, :conditions => ['products.products_availability = ?',  '-1']
  named_scope :include_products, :include => :product
  named_scope :by_product, lambda {|product| {:conditions => {:product_id => product.to_param}}}
  named_scope :limit, lambda {|limit| {:limit => limit}}

  def self.wishlist_source(params, wishlist_source)
    if params[:view_mode] == 'recommended'
      source = wishlist_source[:recommendation]
    elsif params[:ppv] == "1"
      source = wishlist_source[:ppv]
    elsif params[:sort] == 'most_viewed' && params[:limit].to_i == 40
      source = wishlist_source[:most_viewed]
    elsif params[:sort] == 'token_month'
      source = wishlist_source[:most_viewed_vod]
    elsif params[:highlight_best_vod] == '1'
      source = wishlist_source[:prefered_vod]
    elsif params[:highlight_best] == '1'
      source = wishlist_source[:prefered]
    elsif params[:view_mode] == 'production_year_all'
      source = wishlist_source[:new]
    elsif params[:sort] == 'production_year_vod'
      source = wishlist_source[:new_vod]
    elsif params[:view_mode] == 'vod_recent'
      source = wishlist_source[:last_added_vod]
    elsif params[:view_mode] == 'recent'
      source = wishlist_source[:last_added]
    elsif params[:view_mode] == 'soon'
      source = wishlist_source[:soon]
    elsif params[:view_mode] == 'vod_soon'
      source = wishlist_source[:soon_vod]
    elsif params[:view_mode] == 'cinema'
      source = wishlist_source[:cinema]
    elsif params[:search]
      source = wishlist_source[:search]
    elsif params[:category_id]
      if params[:filter] == 'vod'
        source = wishlist_source[:category_vod]
      else
        source = wishlist_source[:category]
      end
    elsif params[:actor_id]
      source = wishlist_source[:actor]
    elsif params[:director_id]
      source = wishlist_source[:director]
    elsif params[:studio_id]
      source = wishlist_source[:studio]
    elsif params[:list_id] && !params[:list_id].blank?
      source = wishlist_source[:theme]
    else
      source = wishlist_source[:product_index]
    end
    source
  end

  def self.notify_hoptoad(message)
    begin
      Airbrake.notify(:error_message => "wishlist_items : #{message}", :backtrace => $@, :environment_name => ENV['RAILS_ENV'])
    rescue => e
      logger.error("wishlist_items : #{message}")
      logger.error(e.backtrace)
    end
  end

  private
  def set_created_at
    self.created_at = Time.now.to_s(:db)
  end

  def set_defaults
    self.type = product.kind
    self.already_rented = customer.assigned_products.include?(product) ? 'YES' : 'NO'
  end

  def self.good_size?(current_customer, qty)
    if current_customer.credit_per_month == 2 or current_customer.credit_per_month == 4
      qty_min =  10
    elsif current_customer.credit_per_month == 6 or current_customer.credit_per_month == 8
      qty_min = 20 
    elsif current_customer.credit_per_month == 0 
      if current_customer.dvds_at_home_count == 2 || current_customer.dvds_at_home_count == 1
        qty_min = 10
      else
        qty_min = 30
      end
    else
      qty_min = 30
    end
    return qty <= qty_min
  end
end
