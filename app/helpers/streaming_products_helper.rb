module StreamingProductsHelper
  def flowplayer(source_file, source, streaming, token_name)
    if source == StreamingProduct.source[:alphanetworks]
      #if caption_file
      #  source = "mp4:120619_FA.mp4"
      #  caption_name = source.gsub(/(mp4:)([0-9_]*)([a-zA-Z]*)(.mp4)/,'\\2')
      #  caption_name = "#{caption_name}#{caption_file.short}.srt"
      #  caption = "captionUrl: '#{caption_name}',"
      #else
      #  caption = ""
      #end
      subtitle = streaming.subtitles.count > 0 ? streaming.subtitles.by_language(:fr).first.short : nil
     #  script = <<-script
     # $f("player", {src: '/flowplayer/flowplayer.commercial-3.2.4.swf'},
     # {
     #   key: '\#$dcba96641dab5d22c24',
     #   version: [10, 0],
     #   clip: {
     #     url: '#{CDN.connect_url(token_name, StreamingProduct.source[:alphanetworks], streaming.languages.by_language(:fr).first.short_alpha, subtitle)}'
     #   },
     #
     #   canvas: {
     #           backgroundColor:'#000000'
     #   },
     #   plugins: {
     #     controls: {
     #       autoHide:
     #       {
     #         "enabled":true,
     #         "mouseOutDelay":500,
     #         "hideDelay":2000,
     #         "hideDuration":400,
     #         "hideStyle":"fade",
     #         "fullscreenOnly":true
     #       }
     #     }
     #   }
     # });
     # script
     
     return "<object width='640' height='377' id='StrobeMediaPlayback' name='StrobeMediaPlayback' type='application/x-shockwave-flash' classid='clsid:d27cdb6e-ae6d-11cf-96b8-444553540000' >
     <param name='movie' value='http://94.139.63.250/swfs/StrobeMediaPlayback.swf' /> <param name='quality' value='high' /> 
     <param name='allowScriptAccess' value='always' /> 
     <param name='bgcolor' value='#000000' /> 
     <param name='allowfullscreen' value='true' /> 
     <param name='flashvars' value= '&src=http://94.139.63.250/#{token_name}/#{streaming.languages.by_language(:fr).first.short_alpha}.f4m&autoHideControlBar=false&streamType=recorded&autoPlay=true'/>
     <embed src='http://94.139.63.250/swfs/StrobeMediaPlayback.swf' width='640' height='377' id='StrobeMediaPlayback' quality='high' allowScriptAccess='always' bgcolor='#000000' name='StrobeMediaPlayback' allowfullscreen='true' pluginspage='http://www.adobe.com/go/getflashplayer' flashvars='&src=http://94.139.63.250/{TOKEN_AUDIO_SUBTITLE}.f4m&autoHideControlBar=false&streamType=recorded&autoPlay=true' type='application/x-shockwave-flash'>
     </embed>
     </object>"
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

  def message_streaming(token, free)
    
    token_status = token.nil? ? Token.status[:invalid] : token.current_status(request.remote_ip)

    if !current_customer.payment_suspended?
      if free == false
        if (current_customer.credits <= 0) && (token.nil? || !token.validate?(request.remote_ip))
          "<div class='attention_vod' id ='credit_empty'>#{t '.credit_empty', :url => edit_customer_reconduction_path(:locale => I18n.locale, :customer_id => current_customer.to_param) }</div>"
        elsif token_status == Token.status[:ip_invalid]
          "<div class ='attention_vod' id ='ip_to_created'>#{t '.ip_to_created'}</div>"
        elsif token_status == Token.status[:expired]
          "<div class ='attention_vod' id ='old_token'>#{t '.old_token'}</div>"
        end
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
end
