class ThemesEvent < ActiveRecord::Base
  db_magic :slaves => [ :slave01, :slave02 ] if ENV['APP'] == "1" && !ENV['SLUG']

  named_scope :selected, :conditions => {:themes_events_selection_id => 3}
  named_scope :selected_beta, :conditions => {:themes_events_selection_id => 2}
  named_scope :by_kind, lambda {|kind| {:conditions => {:kind => kind.to_s}}}
  named_scope :old, :conditions => {:themes_events_selection_id => [4]}
  named_scope :hp, :conditions => {:banner_hp => true}
  named_scope :ordered, :order => "themes_events_selection_id asc, id desc"
  named_scope :limit, lambda {|limit| {:limit => limit}}
  named_scope :ordered_rand, :order => "rand()"

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

  def image_home_page
    "#{DVDPost.images_path}/themes/#{I18n.locale}/home_page/#{id}.jpg"
  end
end
