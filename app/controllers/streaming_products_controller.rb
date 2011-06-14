class StreamingProductsController < ApplicationController
  def show
    @streaming_prefered = StreamingProduct.group_by_version.get_prefered_streaming_by_imdb_id(params[:id], I18n.locale)
    @streaming_not_prefered = StreamingProduct.group_by_version.get_not_prefered_streaming_by_imdb_id(params[:id], I18n.locale)
    @product = Product.both_available.find_by_imdb_id(params[:id])
    @streaming_free = StreamingProductsFree.by_imdb_id(params[:id]).available.count > 0 
   
    respond_to do |format|
      format.html do
        if @product
          @token = current_customer.get_token(@product.imdb_id)
          @token_valid = @token.nil? ? false : @token.validate?(request.remote_ip)
          if streaming_access?
            if !@streaming_prefered.blank? || !@streaming_not_prefered.blank?
             render :action => :show
            else
              flash[:error] = t('streaming_products.not_available.not_available')
              redirect_to root_path
            end
          else
             flash[:error] = t('streaming_products.no_access.no_access')
             redirect_to root_path
          end  
        else
          flash[:error] = t('streaming_products.not_available.not_available')
          redirect_to root_path
        end
      end
      format.js do
        if streaming_access? 
          streaming_version = StreamingProduct.find_by_id(params[:streaming_product_id])
          if !current_customer.suspended? && !Token.dvdpost_ip?(request.remote_ip)
            @token = current_customer.get_token(@product.imdb_id)
            status = @token.nil? ? nil : @token.current_status(request.remote_ip)
            streaming_version = StreamingProduct.find_by_id(params[:streaming_product_id])
            if !@token || status == Token.status[:expired]
              creation = current_customer.create_token(params[:id], @product, request.remote_ip)
              @token = creation[:token]
              error = creation[:error]
              
              if @token
                if @streaming_free
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
                  vod_selection = DVDPost.mail_vod_selection(current_customer.to_param)
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
            current_customer.remove_product_from_wishlist(params[:id], request.remote_ip)
            StreamingViewingHistory.create(:streaming_product_id => params[:streaming_product_id], :token_id => @token.to_param)
            Customer.send_evidence('PlayStart', @product.to_param, current_customer, request.remote_ip)
            
            render :partial => 'streaming_products/player', :locals => {:token => @token, :filename => streaming_version.filename, :source => streaming_version.source, :caption_file => @sub }, :layout => false
          elsif Token.dvdpost_ip?(request.remote_ip)
            render :partial => 'streaming_products/player', :locals => {:token => nil, :filename => streaming_version.filename, :source => streaming_version.source, :caption_file => @sub }, :layout => false
          else
            render :partial => 'streaming_products/no_player', :locals => {:token => @token, :error => error}, :layout => false
          end
        else
          render :partial => 'streaming_products/no_access', :layout => false
        end
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
end