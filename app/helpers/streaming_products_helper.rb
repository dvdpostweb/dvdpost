module StreamingProductsHelper
  def flowplayer(source_file, source, streaming, token_name, browser)
    Rails.logger.debug { "@@@#{browser.tablet?}" }
      if browser.iphone? || browser.ipad? || mobile_request? || browser.tablet?
        audio = streaming.languages.by_language(:fr).first.short_alpha
        sub = streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short_alpha : 'non'
        url = DVDPost.hls_url(token_name, audio, sub)
        if mobile_request?
          #$("#presentation").html("<video id='my_video_1' class='video-js vjs-default-skin' controls width='290' height='132' data-setup='{}'><source src='#{url}' type='application/vnd.apple.mpegurl'></video><a href='#{url}'>#{url}</a>")
            script = "<video id='my_video_1' class='video-js vjs-default-skin' vjs-default-skin' width='290' height='132'  src='#{url}' controls='controls' data-setup='{}'></video>"
        elsif browser.iphone? || browser.tablet?
          script = <<-script
          $("#player").html("<video  width='696' height='389' src='#{url}'></video>")
          script
        else
          script = <<-script
            window.location.href ='#{url}'
          script
        end
      else
        script = <<-script
        $("#player").html("<object width='696' height='389'><param name='movie' value='http://#{DVDPost.streaming_url}/StrobeMediaPlayback.swf'></param><param name='flashvars' value='src=http://#{DVDPost.streaming_url}/#{token_name}_#{streaming.languages.by_language(:fr).first.short_alpha}_#{streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short_alpha : 'non'}.f4m&loop=false&autoPlay=true&streamType=recorded&verbose=true&initialBufferTime=5&expandedBufferTime=30'></param><param name='allowFullScreen' value='true'></param><param name='allowscriptaccess' value='always'></param><embed src='http://#{DVDPost.streaming_url}/StrobeMediaPlayback.swf' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='696' height='389' flashvars='src=http://#{DVDPost.streaming_url}/#{token_name}_#{streaming.languages.by_language(:fr).first.short_alpha}_#{streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short_alpha : 'non'}.f4m&loop=false&autoPlay=true&streamType=recorded&verbose=true&initialBufferTime=5&expandedBufferTime=30'></embed></object>")
        script
      end
      Rails.logger.debug { "@@@#{script}" }
    if mobile_request?
      script
    else
      javascript_tag script
    end

  end

  def message_streaming(token, free, streaming)
    token_status = token.nil? ? Token.status[:invalid] : token.current_status(request.remote_ip)
    if !current_customer.suspended?
      if free[:status] == false
        if current_customer.abo_active == 0
          if current_customer.beta_test
            "<div class ='attention_vod' id ='customer_not_activated'>#{t '.customer_not_activated_beta_test', :link => info_path(:page_name => :promotion)}</div>"
          else
            "<div class ='attention_vod' id ='customer_not_activated'>#{t '.customer_not_activated'}</div>"
          end
        elsif (current_customer.credits < streaming.credits) && (token.nil? || !token.validate?(request.remote_ip))
          nb_credit = "#{streaming.credits} #{ streaming.credits == 1 ? t('customer.credit') : t('customer.credits')}"
          "<div class='attention_vod' id ='credit_empty'>#{t '.credit_empty', :credits => nb_credit, :url => edit_customer_reconduction_path(:locale => I18n.locale, :customer_id => current_customer.to_param) }</div>"
        elsif token_status == Token.status[:expired]
          "<div class ='attention_vod' id ='old_token'>#{t '.old_token'}</div>"
        end
      elsif free[:status] == true && free[:available] == false && (token.nil? || !token.validate?(request.remote_ip))
        "<div class ='attention_vod' id ='old_token'>#{t '.already_used'}</div>"
      end
    else
      if current_customer.payment_suspended?
        "<div class='attention_vod' id=''>#{t '.customer_payment_suspended'}</div>"
      else
        "<div class='attention_vod'>#{t('.customer_holidays_suspended', :date => current_customer.suspensions.holidays.last.date_end.strftime('%d/%m/%Y')) }</div>"
      end
    end
  end
      

  def validation(imdb_id, remote_ip, vlavla)
    {:token => nil, :status => Token.status[:FAILED]} 
  end
      

  def message_error(error)
    case error
      when Token.error[:query_rollback] then
        t('.rollback')
      when Token.error[:customer_not_activated] then
        t('.customer_not_activated')
      when Token.error[:abo_process_error] then
        t('.abo_process')
      when Token.error[:not_enough_credit] then
        t('.credit_empty', :credits => "1 #{t('customer.credit')}", :url => edit_customer_reconduction_path(:locale => I18n.locale, :customer_id => current_customer.to_param))
      when Token.error[:user_suspended] then
        t('.customer_suspended')
      when Token.error[:user_holidays_suspended] then
        t('.user_holidays_suspended')
      when Token.error[:generation_token_failed] then
        t('.rollback')
    end
  end
  
  def get_style(current_abo_credit, abo_credits, showing)
    if(current_abo_credit.to_i < abo_credits.to_i)
      if showing
        "table-row"
      else
        "none"
      end
    else
      "none"
    end
  end

  def icon_tv
    if params[:kind] == :adult
      "icon_tv_adult.gif"
    else
      "icon_tv.gif"
    end
  end

  def icon_infos
    if params[:kind] == :adult
      "icon_infos_adult.gif"
    else
      "icon_infos.gif"
    end
  end

  def icon_survey
    if params[:kind] == :adult
      "icon_survey_adult.gif"
    else
      "icon_survey.gif"
    end
  end

  def icon_problem
    if params[:kind] == :adult
      "icon_problem_adult.gif"
    else
      "icon_problem.gif"
    end
  end
end
