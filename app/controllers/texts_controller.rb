require 'net/sftp'
class TextsController < ApplicationController
  before_filter :get_data
  before_filter :http_authenticate
  def new
  end
  def create
    if params[:landing_id]
      @title_fr = Translation.create(:tr_key => "title_#{params['landing_id']}", :text => params[:title_fr], :namespace => 'home.index.carousel_item_title', :locale_id => 2)
      @title_nl = Translation.create(:tr_key => "title_#{params['landing_id']}", :text => params[:title_nl], :namespace => 'home.index.carousel_item_title', :locale_id => 3)
      @title_en = Translation.create(:tr_key => "title_#{params['landing_id']}", :text => params[:title_en], :namespace => 'home.index.carousel_item_title', :locale_id => 1)
      @name_fr = Translation.create(:tr_key => "name_#{params['landing_id']}", :text => params[:name_fr], :namespace => 'home.index.carousel_item', :locale_id => 2)
      @name_nl = Translation.create(:tr_key => "name_#{params['landing_id']}", :text => params[:name_nl], :namespace => 'home.index.carousel_item', :locale_id => 3)
      @name_en = Translation.create(:tr_key => "name_#{params['landing_id']}", :text => params[:name_en], :namespace => 'home.index.carousel_item', :locale_id => 1)
      @link_fr = Translation.create(:tr_key => "link_#{params['landing_id']}", :text => params[:link_fr], :namespace => 'home.index.carousel_item', :locale_id => 2)
      @link_nl = Translation.create(:tr_key => "link_#{params['landing_id']}", :text => params[:link_nl], :namespace => 'home.index.carousel_item', :locale_id => 3)
      @link_en = Translation.create(:tr_key => "link_#{params['landing_id']}", :text => params[:link_en], :namespace => 'home.index.carousel_item', :locale_id => 1)
    else
      @title_fr = Translation.create(:tr_key => "event_name_#{params['theme_id']}", :text => params[:title_fr], :namespace => 'home.index.theme_of_week', :locale_id => 2)
      @title_nl = Translation.create(:tr_key => "event_name_#{params['theme_id']}", :text => params[:title_nl], :namespace => 'home.index.theme_of_week', :locale_id => 3)
      @title_en = Translation.create(:tr_key => "event_name_#{params['theme_id']}", :text => params[:title_en], :namespace => 'home.index.theme_of_week', :locale_id => 1)
    end

  end
  def edit
  end
  def update
    if params[:landing_id]
      @title_fr.update_attribute(:text, params[:title_fr])
      @title_nl.update_attribute(:text, params[:title_nl])
      @title_en.update_attribute(:text, params[:title_en])
      @name_fr.update_attribute(:text, params[:name_fr])
      @name_nl.update_attribute(:text, params[:name_nl])
      @name_en.update_attribute(:text, params[:name_en])
      @link_fr.update_attribute(:text, params[:link_fr])
      @link_nl.update_attribute(:text, params[:link_nl])
      @link_en.update_attribute(:text, params[:link_en])

    if params[:file_web] || params[:file_iphone] || params[:file_ipad]
      Net::SFTP.start('192.168.100.205', 'dvdpost', :password => '(:melissa:)') do |sftp|
        sftp.upload!(params[:file_web] , '/data/sites/benelux/images/landings/'+@landing.id.to_s+'.jpg') if params[:file_web]
        sftp.upload!(params[:file_ipad] , '/data/sites/benelux/images/landingsipad/'+@landing.id.to_s+'.jpg') if params[:file_ipad]
        sftp.upload!(params[:file_iphone] , '/data/sites/benelux/images/landingsiphone/'+@landing.id.to_s+'.jpg') if params[:file_iphone]
      end
    end
    @landing.update_attributes(:reference_id => params[:reference_id], :actif_french => params[:actif_french], :actif_dutch => params[:actif_dutch], :actif_english => params[:actif_english], :login => params[:login] ) 
    else
      @title_fr.update_attribute(:text, params[:title_fr])
      @title_nl.update_attribute(:text, params[:title_nl])
      @title_en.update_attribute(:text, params[:title_en])
    end
    [1,2,3].each do |locale_id| 
    
      locale = Locale.find(locale_id)
      raise "wrong locale" unless locale
      locale.short_will_change! # any field in fact, we just need to bump the updated_at attribute
      locale.save!
      
      Locale.uncached do
        locale = Locale.find(locale_id)
        Rails.cache.write("locale_versions/#{locale.short}", locale.updated_at)
      end
    end 
  end
  def get_data
    if params[:landing_id]
      @landing = Landing.find(params[:landing_id])
      @title = Landing.find(params[:landing_id]).name
      @title_fr = Locale.find(2).translations.find_by_tr_key("title_#{params[:landing_id]}")
      @title_nl = Locale.find(3).translations.find_by_tr_key("title_#{params[:landing_id]}")
      @title_en = Locale.find(1).translations.find_by_tr_key("title_#{params[:landing_id]}")
      @name_fr = Locale.find(2).translations.find_by_tr_key("name_#{params[:landing_id]}")
      @name_nl = Locale.find(3).translations.find_by_tr_key("name_#{params[:landing_id]}")
      @name_en = Locale.find(1).translations.find_by_tr_key("name_#{params[:landing_id]}")
      @link_fr = Locale.find(2).translations.find_by_tr_key("link_#{params[:landing_id]}")
      @link_nl = Locale.find(3).translations.find_by_tr_key("link_#{params[:landing_id]}")
      @link_en = Locale.find(1).translations.find_by_tr_key("link_#{params[:landing_id]}")
    else
      @title = ThemesEvent.find(params[:theme_id]).name
      @title_fr = Locale.find(2).translations.find_by_tr_key("event_name_#{params[:theme_id]}")
      @title_nl = Locale.find(3).translations.find_by_tr_key("event_name_#{params[:theme_id]}")
      @title_en = Locale.find(1).translations.find_by_tr_key("event_name_#{params[:theme_id]}")
    end
  end
  def index
  end                                                                                
end