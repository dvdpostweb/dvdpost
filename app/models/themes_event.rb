class ThemesEvent < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']

  named_scope :selected, :conditions => {:themes_events_selection_id => 1}
  named_scope :selected_beta, :conditions => {:themes_events_selection_id => 2}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => kind.to_s}}}
  named_scope :old, :conditions => {:themes_events_selection_id => 3}
  

  has_friendly_id :name, :use_slug => true, :approximate_ascii => true
  
  def image_logo
    "#{DVDPost.images_path}/themes/#{I18n.locale}/logo/#{id}.gif"
  end
  
  def image_header
    "#{DVDPost.images_path}/themes/#{I18n.locale}/banner_page/#{id}.jpg"
  end

  def image_wallpaper
    "#{DVDPost.images_path}/themes/#{I18n.locale}/wallpaper/#{id}.jpg"
  end

  def image_title
    "#{DVDPost.images_path}/themes/#{I18n.locale}/title_page/#{id}.jpg"
  end

  def image_thumbs
    "#{DVDPost.images_path}/themes/#{I18n.locale}/thumbs/#{id}.gif"
  end
end
