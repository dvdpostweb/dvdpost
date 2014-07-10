class LandingsController < ApplicationController
  before_filter :http_authenticate
  
  def index
    @landings = Landing.order_admin.paginate(:per_page => 30, :page => params[:page])
  end

  def new
	@landing = Landing.new
  end

  def create
    if params[:file_web] || params[:file_iphone] || params[:file_ipad]
      Net::SFTP.start('pekin', 'dvdpost', :password => '(:melissa:)') do |sftp|
        sftp.upload!(params[:file_web] , '/data/sites/benelux/images/landings/'+@landing.id.to_s+'.jpg') if params[:file_web]
        sftp.upload!(params[:file_ipad] , '/data/sites/benelux/images/landingsipad/'+@landing.id.to_s+'.jpg') if params[:file_ipad]
        sftp.upload!(params[:file_iphone] , '/data/sites/benelux/images/landingsiphone/'+@landing.id.to_s+'.jpg') if params[:file_iphone]
      end
    end
    @landing = Landing.create(:name => params[:title_fr], :reference_id => params[:reference_id], :actif_french => params[:actif_french], :actif_dutch => params[:actif_dutch], :actif_english => params[:actif_english], :login => params[:login] ) 
    [1,2,3].each do |i|
      locale = case i
      when 2
        :fr
      when 1
        :en
      else
        :nl
      end
      Translation.create(:tr_key => "title_#{@landing.id}", :locale_id => i, :text => params["title_#{locale}"], :namespace => 'home.index.carousel_item_title')
      Translation.create(:tr_key => "name_#{@landing.id}", :locale_id => i, :text => params["name_#{locale}"], :namespace => 'home.index.carousel_item')
      Translation.create(:tr_key => "link_#{@landing.id}", :locale_id => i, :text => params["link_#{locale}"], :namespace => 'home.index.carousel_item') if params["link_#{locale}"]
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
    redirect_to landings_path
  end
end