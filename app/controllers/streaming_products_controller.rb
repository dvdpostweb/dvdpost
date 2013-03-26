class StreamingProductsController < ApplicationController
  #before_filter :ppv_ready?, :only => [:show]
  before_filter :vod_lux?, :only => [:show]

  def show
    @vod_create_token = General.find_by_CodeType('VOD_CREATE_TOKEN').value
    @vod_disable = General.find_by_CodeType('VOD_ONLINE').value
    if Rails.env == 'production' 
      @product = Product.both_available.find_by_imdb_id(params[:id])
    else
      @product = Product.find_by_imdb_id(params[:id])
    end
    if @product
      if ENV['HOST_OK'] == "1"
        @token = Token.recent(2.week.ago.localtime, Time.now).is_public.by_imdb_id(@product.imdb_id).find_by_code(params[:code]) if !params[:code].nil?
      else
        @token = current_customer.get_token(@product.imdb_id)
      end
    end
    @token_valid = @token.nil? ? false : @token.validate?(request.remote_ip)
    if Rails.env == 'production' && @token_valid == false
      @streaming = StreamingProduct.available.find_by_imdb_id(params[:id])
      @streaming_prefered = StreamingProduct.group_by_language.available.find_all_by_imdb_id(params[:id], I18n.locale)
      @streaming_not_prefered = nil
    elsif Rails.env == 'production' && @token_valid == true
      @streaming = StreamingProduct.available_token.find_by_imdb_id(params[:id])
      @streaming_prefered = StreamingProduct.group_by_language.available_token.find_all_by_imdb_id(params[:id], I18n.locale)
      @streaming_not_prefered = nil
    else
      @streaming = StreamingProduct.available_beta.alpha.find_by_imdb_id(params[:id])
      @streaming_prefered = StreamingProduct.alpha.group_by_language.find_all_by_imdb_id(params[:id], I18n.locale)
      @streaming_not_prefered = nil
    end
    if params[:code]
      @code = StreamingCode.find_by_name(params[:code]) 
      if @code.nil? && params[:uniq]
        @code = @streaming.generate_code(params[:code], params[:uniq])
      end
    end
    @streaming_free = streaming_free(@product)
    respond_to do |format|
      
      
      format.html do
        if @product
          if @vod_disable == "1" || Rails.env == "pre_production"
            if streaming_access?
              if !@streaming_prefered.blank? || !@streaming_not_prefered.blank?
                if @token_valid == false && @vod_create_token == "0" && Rails.env != "pre_production"
                  error = t('streaming_products.not_available.offline')
                  show_error(error, @code)
                else
                  render :action => :show
                end
              else
                error = t('streaming_products.not_available.not_available')
                show_error(error, @code)
              end
            else
               error = t('streaming_products.no_access.no_access')
               show_error(error, @code)
            end  
          else
            error = t('streaming_products.not_available.offline')
            show_error(error, @code)
          end
        else
          error = t('streaming_products.not_available.not_available')
          show_error(error, @code)
        end
      end
      format.js do
        if streaming_access?
          streaming_version = StreamingProduct.find_by_id(params[:streaming_product_id])
          if ENV['HOST_OK'] == "1" || (!current_customer.suspended? && !Token.dvdpost_ip?(request.remote_ip) && !current_customer.super_user? && !(/^192(.*)/.match(request.remote_ip)))
            status = @token.nil? ? nil : @token.current_status(request.remote_ip)
            streaming_version = StreamingProduct.find_by_id(params[:streaming_product_id])
            if !@token || status == Token.status[:expired]
              if ENV['HOST_OK'] == "0"
                creation = current_customer.create_token(params[:id], @product, request.remote_ip, params[:streaming_product_id], params[:kind])
              elsif ENV['HOST_OK'] == "1" && !params[:code].nil?
                creation = Token.create_token(params[:id], @product, request.remote_ip, params[:streaming_product_id], params[:kind], params[:code])
              else
                creation = nil
              end
              if creation
                @token = creation[:token]
                error = creation[:error]
              
                if current_customer && @token
                  if @streaming_free[:status] == true
                    mail_id = DVDPost.email[:streaming_product_free]
                  else
                    mail_id = DVDPost.email[:streaming_product]
                  end
                  product_id = @product.id
                  if current_customer.gender == 'm' 
                    gender = t('mails.gender_male')
                  else
                    gender = t('mails.gender_female')
                  end
                    movie_detail = DVDPost.mail_movie_detail(current_customer.to_param, @product.id)
                    vod_selection = DVDPost.mail_vod_selection(current_customer.to_param, params[:kind])
                    recommendation_dvd_to_dvd = DVDPost.mail_recommendation_dvd_to_dvd(current_customer.to_param, @product.id)
                    options = 
                    {
                      "\\$\\$\\$customers_name\\$\\$\\$" => "#{current_customer.first_name.capitalize} #{current_customer.last_name.capitalize}",
                      "\\$\\$\\$gender_simple\\$\\$\\$" => gender ,
                      "\\$\\$\\$movie_details\\$\\$\\$" => movie_detail,
                      "\\$\\$\\$selection_vod\\$\\$\\$" => vod_selection,
                      "\\$\\$\\$date\\$\\$\\$" => Time.now.strftime('%d/%m/%Y'),
                      "\\$\\$\\$recommendation_dvd_to_dvd\\$\\$\\$" => recommendation_dvd_to_dvd,
                    }
                    send_message(mail_id, options)
                
                end
              end
            end
          else
            if current_customer.payment_suspended?
              error = Token.error[:user_suspended]
            else
              error = Token.error[:user_holidays_suspended]
            end
          end
          if params[:subtitle_id]
            @sub = Subtitle.find(params[:subtitle_id])
          else
            @sub = nil
          end
          if @token
            current_customer.remove_product_from_wishlist(params[:id], request.remote_ip) if current_customer
            StreamingViewingHistory.create(:streaming_product_id => params[:streaming_product_id], :token_id => @token.to_param, :ip => request.remote_ip)
            Customer.send_evidence('PlayStart', @product.to_param, current_customer, request.remote_ip, {:responseid => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser) , :rule => params[:source]}) if current_customer
            render :partial => 'streaming_products/player', :locals => {:token => @token, :filename => streaming_version.filename, :source => streaming_version.source, :streaming => streaming_version, :browser => @browser }, :layout => false
          elsif Token.dvdpost_ip?(request.remote_ip) || current_customer.super_user? || (/^192(.*)/.match(request.remote_ip))
            render :partial => 'streaming_products/player', :locals => {:token => @token, :filename => streaming_version.filename, :source => streaming_version.source, :streaming => streaming_version, :browser => @browser }, :layout => false
            Customer.send_evidence('PlayStart', @product.to_param, current_customer, request.remote_ip, {:responseid => params[:response_id], :segment1 => params[:source], :formFactor => format_text(@browser) , :rule => params[:source]}) if current_customer
          else
            render :partial => 'streaming_products/no_player', :locals => {:token => @token, :error => error}, :layout => false
          end
        else
          render :partial => 'streaming_products/no_access', :layout => false
        end
      end
    end
  end

  def language
    if ENV['HOST_OK'] == "1"
      token = Token.recent(2.week.ago.localtime, Time.now).is_public.by_imdb_id(params[:streaming_product_id]).find_by_code(params[:code]) if !params[:code].nil?
    else
      token = current_customer.get_token(params[:streaming_product_id])
    end
    token_valid = token.nil? ? false : token.validate?(request.remote_ip)
    if Rails.env == 'production' && token_valid == false
      @streaming_subtitle = StreamingProduct.available.by_language(params[:language_id]).find_all_by_imdb_id(params[:streaming_product_id])
    elsif Rails.env == 'production' && token_valid == true
      @streaming_subtitle = StreamingProduct.available_token.by_language(params[:language_id]).find_all_by_imdb_id(params[:streaming_product_id])
    else
      @streaming_subtitle = StreamingProduct.available_beta.alpha.by_language(params[:language_id]).find_all_by_imdb_id(params[:streaming_product_id])
    end
    render :partial => 'streaming_products/show/subtitles', :locals => {:streaming => @streaming_subtitle, :sample => params[:sample]}, :layout => false
  end

  def subtitle
    if ENV['HOST_OK'] == "1"
      token = Token.recent(2.week.ago.localtime, Time.now).is_public.by_imdb_id(params[:streaming_product_id]).find_by_code(params[:code]) if !params[:code].nil?
    else
      token = current_customer.get_token(params[:streaming_product_id])
    end
    token_valid = token.nil? ? false : token.validate?(request.remote_ip)
    if Rails.env == 'production' && token_valid == false
      @streaming = StreamingProduct.available.find(params[:id])
    elsif Rails.env == 'production' && token_valid == true
      @streaming = StreamingProduct.available_token.find(params[:id])
    else
      @streaming = StreamingProduct.available_beta.alpha.find(params[:id])
    end
    render :partial => 'streaming_products/show/launch', :locals => {:streaming => @streaming}, :layout => false
  end

  def versions
    if ENV['HOST_OK'] == "1"
      token = Token.recent(2.week.ago.localtime, Time.now).is_public.by_imdb_id(params[:streaming_product_id]).find_by_code(params[:code]) if !params[:code].nil?
    else
      token = current_customer.get_token(params[:streaming_product_id])
    end
    token_valid = token.nil? ? false : token.validate?(request.remote_ip)
    if Rails.env == 'production' && token_valid == false
      @streaming_prefered = StreamingProduct.available.find_all_by_imdb_id(params[:streaming_product_id], I18n.locale) 
    elsif Rails.env == 'production' && token_valid == true
      @streaming_prefered = StreamingProduct.available_token.find_all_by_imdb_id(params[:streaming_product_id], I18n.locale) 
    else
      @streaming_prefered = StreamingProduct.available_beta.alpha.find_all_by_imdb_id(params[:streaming_product_id], I18n.locale) 
    end
    render :partial => '/streaming_products/show/versions', :locals => {:version => @streaming_prefered, :source => params[:source],  :response_id => params[:response_id]}
  end

  def sample
    params[:id] = DVDPost.data_sample[params[:kind]][:imdb_id]
    product_id = DVDPost.data_sample[params[:kind]][:product_id]
    @product = Product.find_by_products_id(product_id)
    @streaming_prefered = StreamingProduct.group_by_language.available.find_all_by_imdb_id(params[:id], I18n.locale)
    @token_name = DVDPost.token_sample[params[:kind]]
    respond_to do |format|
      format.html do
      end
      format.js do
         @streaming = StreamingProduct.find_by_id(params[:streaming_product_id])
         render :layout => false
      end
    end
  end

  def faq
    @product = Product.find_by_imdb_id(params[:streaming_product_id])
    unless current_customer
      @hide_menu = false
      @customer_id = 0
    else
      @customer_id = current_customer.to_param
    end
  end

  def show_error(error, code)
    if code.nil?
      flash[:error] = error
      redirect_to root_path
    else
      render :partial => '/streaming_products/show/error', :layout => true, :locals => {:error => error}
    end
  end

  private
  def ppv_ready?
    @streaming = StreamingProduct.available.find_by_imdb_id(params[:id])
    if current_customer and streaming.is_ppv && current_customer.ppv_status_id != 1
      redirect_to root_path
    end
  end
  
  def vod_lux?
    if params[:id] && Product.find_by_imdb_id(params[:id]) && !Product.find_by_imdb_id(params[:id]).streaming?(params[:kind], session[:country_id])
      redirect_to root_path
    end
  end
  
end