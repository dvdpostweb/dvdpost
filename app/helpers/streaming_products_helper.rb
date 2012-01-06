module StreamingProductsHelper
  def flowplayer(source_file, source, streaming, token_name, browser)
    if source == StreamingProduct.source[:alphanetworks]
      if browser.iphone? && browser.mobile?
        audio = streaming.languages.by_language(:fr).first.short_alpha
        sub = streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short_alpha : 'non'
        url = hls_url(token_name, audio, sub)
        script = <<-script
        $("#player").html("<video  width='696' height='389' src="#{url}"></video>")
        script
        
      else
        script = <<-script
        $("#player").html("<object width='696' height='389'><param name='movie' value='http://vod.dvdpost.be:8081/swf/StrobeMediaPlayback.swf'/><param name='FlashVars' value='src=http://vod.dvdpost.be/#{token_name}_#{streaming.languages.by_language(:fr).first.short_alpha}_#{streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short_alpha : 'non'}.f4m'/><param name='allowFullScreen' value='true'/><param name='allowscriptaccess' value='always'/><embed src='http://vod.dvdpost.be:8081/swf/StrobeMediaPlayback.swf' type='application/x-shockwave-flash' allowscriptaccess='always' allowfullscreen='true' width='696' height='389' flashvars='src=http://vod.dvdpost.be/#{token_name}_#{streaming.languages.by_language(:fr).first.short_alpha}_#{streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short_alpha : 'non'}.f4m'/></object>")
        script
      end
    else
      script = <<-script
      $f("player", {src: '/flowplayer/flowplayer.commercial-3.2.4.swf'},
      {
        key: '\#$dcba96641dab5d22c24',
        version: [10, 0],
        clip: {
          url: '#{source_file}',
          provider: 'softlayer'
        },
        canvas: {
        		backgroundColor:'#000000'
        },
        plugins: {
          softlayer: {
            url: '/flowplayer/flowplayer.rtmp-3.1.3.swf',
            netConnectionUrl: '#{CDN.connect_url(token_name, StreamingProduct.source[:softlayer])}'
          },
          controls: {
            autoHide:
            {
              "enabled":true,
              "mouseOutDelay":500,
              "hideDelay":2000,
              "hideDuration":400,
              "hideStyle":"fade",
              "fullscreenOnly":true
            }
          }
        }
      });
      script
    end
    javascript_tag script
  end

  def message_streaming(token, free, streaming)
    token_status = token.nil? ? Token.status[:invalid] : token.current_status(request.remote_ip)
    if !current_customer.payment_suspended?
      if free[:status] == false
        if current_customer.abo_active == 0
          if current_customer.beta_test
            "<div class ='attention_vod' id ='customer_not_activated'>#{t '.customer_not_activated_beta_test', :link => info_path(:page_name => :promotion)}</div>"
          else
            "<div class ='attention_vod' id ='customer_not_activated'>#{t '.customer_not_activated'}</div>"
          end
        elsif (current_customer.credits < streaming.credits) && (token.nil? || !token.validate?(request.remote_ip))
          "<div class='attention_vod' id ='credit_empty'>#{t '.credit_empty', :url => edit_customer_reconduction_path(:locale => I18n.locale, :customer_id => current_customer.to_param) }</div>"
        elsif token_status == Token.status[:ip_invalid]
          "<div class ='attention_vod' id ='ip_to_created'>#{t '.ip_to_created'}</div>"
        elsif token_status == Token.status[:expired]
          "<div class ='attention_vod' id ='old_token'>#{t '.old_token'}</div>"
        end
      elsif free[:status] == true && free[:available] == false && (token.nil? || !token.validate?(request.remote_ip))
        "<div class ='attention_vod' id ='old_token'>#{t '.already_used'}</div>"
      end
    else
      "<div class='attention_vod' id=''>#{t '.customer_suspended'}</div>"
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
        t('.credit_empty', :url => edit_customer_reconduction_path(:locale => I18n.locale, :customer_id => current_customer.to_param))
      when Token.error[:user_suspended] then
        t('.customer_suspended')
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
