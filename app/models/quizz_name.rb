class QuizzName < ActiveRecord::Base
  db_magic :slave => :slave01 if ENV['APP'] == "1"

  set_table_name :quizz_name

  set_primary_key :quizz_name_id
  
  
  alias_attribute :name, :quizz_name
  alias_attribute :type, :quizz_type

  named_scope :normal_available, :conditions => ['products_status != :status AND products_type = :kind', {:status => '-1', :kind => DVDPost.product_kinds[:normal]}]
  named_scope :previous_list, lambda{|limit| {:conditions => ['focus = 2'], :limit => limit}}
  named_scope :ordered, :order => 'quizz_name_id desc'

  def self.on_focus
    find_by_focus(1)
  end

  def image
    File.join(DVDPost.images_language_path[I18n.locale], banner) unless banner.empty?
  end
end
