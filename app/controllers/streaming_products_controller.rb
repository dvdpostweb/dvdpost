class StreamingProductsController < ApplicationController
  def show
    @vod_create_token = General.find_by_CodeType('VOD_CREATE_TOKEN').value
    @vod_disable = General.find_by_CodeType('VOD_ONLINE').value
    if Rails.env == 'production' 
      @product = Product.both_available.find_by_imdb_id(params[:id])
      @streaming = StreamingProduct.available.find_by_imdb_id(params[:id])
      @streaming_prefered = StreamingProduct.group_by_language.available.find_all_by_imdb_id(params[:id], I18n.locale)
      @streaming_not_prefered = nil
    else
      @streaming = StreamingProduct.available_beta.alpha.find_by_imdb_id(params[:id])
      @streaming_prefered = StreamingProduct.alpha.group_by_language.find_all_by_imdb_id(params[:id], I18n.locale)
      @streaming_not_prefered = nil
      @product = Product.find_by_imdb_id(params[:id])
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
          if ENV['HOST_OK'] == "1"
            @token = Token.recent(2.week.ago.localtime, Time.now).by_imdb_id(@product.imdb_id).find_by_code(params[:code])
          else
            @token = current_customer.get_token(@product.imdb_id)
          end
          @token_valid = @token.nil? ? false : @token.validate?(request.remote_ip)
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
          if ENV['HOST_OK'] == "1"
            @token = Token.recent(2.week.ago.localtime, Time.now).by_imdb_id(@product.imdb_id).find_by_code(params[:code])
          else
            @token = current_customer.get_token(@product.imdb_id)
          end
          if ENV['HOST_OK'] == "1" || (!current_customer.suspended? && !Token.dvdpost_ip?(request.remote_ip))
            status = @token.nil? ? nil : @token.current_status(request.remote_ip)
            
            streaming_version = StreamingProduct.find_by_id(params[:streaming_product_id])
            if !@token || status == Token.status[:expired]
              if ENV['HOST_OK'] == "0"
                creation = current_customer.create_token(params[:id], @product, request.remote_ip, params[:streaming_product_id], params[:kind])
              else
                creation = Token.create_token(params[:id], @product, request.remote_ip, params[:streaming_product_id], params[:kind], params[:code])
              end
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
               
            else
              #token is valid but new ip to generate
              if status == Token.status[:ip_valid]
                result_token_ip = current_customer.create_token_ip(@token,request.remote_ip)
                if result_token_ip != true
                  @token = nil
                  error = result_token_ip
                end
              # token is valid - new ip - ip available 0 => created 2 new ip
              elsif status == Token.status[:ip_invalid]
                creation = current_customer.create_more_ip(@token, request.remote_ip)
                @token = creation[:token]
                error = creation[:error]
              end
            end
          else
            error = Token.error[:user_suspended]
          end
          if params[:subtitle_id]
            @sub = Subtitle.find(params[:subtitle_id])
          else
            @sub = nil
          end
          if @token
            current_customer.remove_product_from_wishlist(params[:id], request.remote_ip) if current_customer
            StreamingViewingHistory.create(:streaming_product_id => params[:streaming_product_id], :token_id => @token.to_param)
            Customer.send_evidence('PlayStart', @product.to_param, current_customer, request.remote_ip) if current_customer
            render :partial => 'streaming_products/player', :locals => {:token => @token, :filename => streaming_version.filename, :source => streaming_version.source, :streaming => streaming_version, :browser => @browser }, :layout => false
          elsif Token.dvdpost_ip?(request.remote_ip)
            render :partial => 'streaming_products/player', :locals => {:token => @token, :filename => streaming_version.filename, :source => streaming_version.source, :streaming => streaming_version, :browser => @browser }, :layout => false
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
    if Rails.env == 'production' 
      @streaming_subtitle = StreamingProduct.available.by_language(params[:language_id]).find_all_by_imdb_id(params[:streaming_product_id])
    else
      @streaming_subtitle = StreamingProduct.available_beta.alpha.by_language(params[:language_id]).find_all_by_imdb_id(params[:streaming_product_id])
    end
    render :partial => 'streaming_products/show/subtitles', :locals => {:streaming => @streaming_subtitle, :sample => params[:sample]}, :layout => false
  end

  def subtitle
    if Rails.env == 'production' 
      @streaming = StreamingProduct.available.find(params[:id])
    else
      @streaming = StreamingProduct.available_beta.alpha.find(params[:id])
    end
    render :partial => 'streaming_products/show/launch', :locals => {:streaming => @streaming}, :layout => false
  end

  def versions
    if Rails.env == 'production' 
      @streaming_prefered = StreamingProduct.available.find_all_by_imdb_id(params[:streaming_product_id], I18n.locale) 
    else
      @streaming_prefered = StreamingProduct.available_beta.alpha.find_all_by_imdb_id(params[:streaming_product_id], I18n.locale) 
    end
    render :partial => '/streaming_products/show/versions', :locals => {:version => @streaming_prefered}
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
      @hide_menu = true
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
end