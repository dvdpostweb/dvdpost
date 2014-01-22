$(function() {
  function goToByScroll(id){
    $('html,body').animate({scrollTop: $("#"+id).offset().top},'slow');
  }
  
  
  var isIE  = (navigator.appVersion.indexOf("MSIE") != -1) ? true : false;
  var isWin = (navigator.appVersion.toLowerCase().indexOf("win") != -1) ? true : false;
  var isOpera = (navigator.userAgent.indexOf("Opera") != -1) ? true : false;

  // JavaScript helper required to detect Flash Player PlugIn version information
  
  function JSGetSwfVer(i){
        // NS/Opera version >= 3 check for Flash plugin in plugin array
        if (navigator.plugins != null && navigator.plugins.length > 0) {
              if (navigator.plugins["Shockwave Flash 2.0"] || navigator.plugins["Shockwave Flash"]) {
                    var swVer2 = navigator.plugins["Shockwave Flash 2.0"] ? " 2.0" : "";
                          var flashDescription = navigator.plugins["Shockwave Flash" + swVer2].description;
                          descArray = flashDescription.split(" ");
                          tempArrayMajor = descArray[2].split(".");
                          versionMajor = tempArrayMajor[0];
                    if ( descArray[3] != "" ) {
                          tempArrayMinor = descArray[3].split("r");
                    } else {
                          tempArrayMinor = descArray[4].split("r");
                    }
                          versionMinor = tempArrayMinor[1] > 0 ? tempArrayMinor[1] : 0;
                          flashVer = parseFloat(versionMajor + "." + versionMinor);
              } else {
                    flashVer = -1;
              }
        }
        // MSN/WebTV 2.6 supports Flash 4
        else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.6") != -1) flashVer = 4;
        // WebTV 2.5 supports Flash 3
        else if (navigator.userAgent.toLowerCase().indexOf("webtv/2.5") != -1) flashVer = 3;
        // older WebTV supports Flash 2
        else if (navigator.userAgent.toLowerCase().indexOf("webtv") != -1) flashVer = 2;
        // Can't detect in all other cases
        else {

              flashVer = -1;
        }
        return flashVer;
  }

  /*for (i=25;i>0;i--) {      
    if (isIE && isWin && !isOpera) {
          versionStr = VBGetSwfVer(i);
    } else {
          versionStr = JSGetSwfVer(i);
    } 
  }*/
  $('#fullscreenon_off').live("click", function() {
    FullscreenOnOff()
  })
  
  $('#play').live("click", function() {
    $(this).hide()
    $('#pause').show()
    Play()
  })
  
  $('#pause').live("click", function() {
    $(this).hide()
    $('#play').show()
    
    Pause()
  })
  
  $('.qualityvod').live("click", function() {
    url = $(this).attr('href')
    var regex = new RegExp(".*/products/([0-9]*).*");
    res = regex.exec(url)
    product_vod_id = $('#product_id').html()
    send_event('Movie', 'PlayStart', product_vod_id,'')
    response_id = getParameterByName('response_id')
    content = $('#presentation').html()
    loader = 'loading.gif';
    $('.error').html('');
    if($('#drm').html() == "1")
    {
      
    }
    else
    {
      $('#player').html('')
    }
    /*$('#player').html('')*/
    $('#presentation').html("<div style='height:389px'><div class='load'><img src='/images/"+loader+"'/></div></div>")
    $(this).hide()
    $.ajax({
      dataType: 'html',
      url: $(this).attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        if(/.m3u8$/.test(data))
        {
          $('#presentation').html('')
          $('.qualityvod').show()
          /*if (/MSIE (\d+\.\d+);/.test(navigator.userAgent))
          {
            $("#player").html('<object id="ViewRightControl" classid="CLSID:059BFDA3-0AAB-419F-9F69-AF9BBE3A4668" width="696" height="389"></object><button type="button" id="play" style="display:none">Play</button><button type="button" id="pause">Pause</button><button id="fullscreenon_off" type="button">Fullscreen</button>');
          }
          else
          {
            $("#player").html('<object id="ViewRightControl" type="application/x-viewright-m3u8" width="696" height="389"></object><button type="button" id="play" style="display:none">Play</button><button type="button" id="pause">Pause</button><button id="fullscreenon_off" type="button">Fullscreen</button>');
          }
          Open($.trim(data))*/
          /*$('#view-right-control').attr('height', 389)*/
          $('#player').css( "display", "block")
          var player = new ViewRightPlayer();
          player.get_player('#player')
          player.open($.trim(data))
        }
        else
        { 
          $('#presentation').html('')
          $('.qualityvod').show()
          $('#flow').html(data);
        }        
        
      },
      error: function() {
        $('#presentation').html(content);
        $('.qualityvod').show();
      }
      
    });
    return false;
  });

  response="#r1"
  $('.q').live('click', function(){
    id = $(this).attr('id');
    try
    {
        $(response).hide();
    }
    catch(e)
    {
    }
    response = "#" + id.replace('q', 'r');
    $(response).show();

    return false;
  })
  function go(text)
  {
    jQuery.facebox(function() {
        jQuery.facebox(text);
    })
    
    
  }
  $.facebox.settings.opacity = 0.4; 
  $.facebox.settings.modal = true; 
  /*versionStr+='';
  v = versionStr.split('.');
  version = parseInt(v[0]);
  if (versionStr == -1 || version <= 9)
  {
    $('.quality').hide();
    go('<div style="width:500px;" class="attention_vod">'+$('#flash_problem').html()+'</div>')
  }*/
  if ($('#old_token').html()!= undefined)
  {
    go('<div style="width:500px;" class="attention_vod">'+$('#old_token').html()+'</div>')
  }
  else if ($('#ip_to_created').html()!=undefined)
  {
    go('<div style="width:500px;" class="attention_vod">'+$('#ip_to_created').html()+'</div>')
  }
 else if ($('#warning').html()!=undefined)
  {
    url = $('#warning').html();
    jQuery.facebox(function() {
      $.ajax({
        url: url,
        dataType: 'html',
        type: 'GET',
        success: function(data) { jQuery.facebox(data); }
      });
    });
    
  }
  $(".stars .star, #cotez .star").live("click", function() {
    url = $(this).parent().attr('href');
    html_item = $(this).parent().parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    if ($(this).attr('src').match(/black-star-/i)){
      loader = 'black-'+loader;
    }
    html_item.html("<img src='/images/"+loader+"'/>");
    $.ajax({dataType: 'html',
      url: url,
      type: 'POST',
      data: {},
      success: function(data) {
        if (url.match(/replace=homepage/)){
          html_item.parent().replaceWith(data);
        }else{
          html_item.html(data);
        }
        
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $(".stars .star, #cotez .star").live("mouseover", function(){
    data = $(this).attr('id').replace('star_','').split('_');
    product_id = data[0];
    rating_value = data[1];

    image = 'star-voted-';
    if ($(this).attr('src').match(/black-star-(on|half|off)/i)){
      image = 'black-'+image;
    }
    if ($(this).attr('src').match(/small-star-(on|half|off)/i)){
      image = 'small-'+image;
      ext = 'png'
    }
    else
    {
      ext = 'jpg'
    }
    
    for(var i=1; i<=5; i++)
    {
      if(i <= rating_value){
        full_image = image+'on';
      }else{
        full_image = image+'off';
      }
      $('#star_'+product_id+"_"+i).attr('src', '/images/'+full_image+'.'+ext);
    }
  });

  $(".stars .star, #cotez .star").live("mouseout", function() {
    product_id = $(this).attr('id').replace('star_','').split('_')[0];
    for(var i=1; i<=5; i++)
    {
      image = $('#star_'+product_id+'_'+i);
      image.attr('src','/images/'+image.attr('name'));
    }
  });
  $("#report").live("click", function() {
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.ajax({
        url: url,
        dataType: 'html',
        type: 'GET',
        success: function(data) { jQuery.facebox(data); }
      });
    });
    
    return false;
  });
  
  $("#cancel").live("click", function(){
    $("body").trigger('close.facebox')
    return false;
  });
  $("#more").live("click", function(){
    $(".choose_color").show();
    $(".choose_empty").show();
    $(this).parent().parent().hide();
    return false;
  });
  
  
  var bc = $('#buttonContainer'); 

  var $container = $('#choice_new').cycle({ 
      fx:     'scrollHorz', 
      speed:   300, 
      timeout: 0 
  }); 

  $(".language_btn").live("click", function() {
    html_item = $(this).parent();
    content = html_item.html();
    /*html_item.html("Loading...");*/
    step = $(this).parent().parent().attr('id')
    if(step == 'step1')
    {
      next = '#step2'
      cycle = 1
    }
    else
    {
      next ='#step3'
      cycle = 2
    }
    root_item = html_item.parent();
    $.ajax({dataType: 'html',
      url: $(this).attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        $(next).html(data);
        $container.cycle(cycle),200;
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });
  $("#all_versions").live("click", function() {
    html_item = $('#all_versions_data');
    content = html_item.html();
    html_item.html("<div ><div style='margin: 0 auto; width:32px'><img src='/images/loading.gif'/></div></div>");
    $.ajax({dataType: 'html',
      url: $(this).attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        $(html_item).html(data);
        
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });
  $("#change_step2").live("click", function() {
    $container.cycle(0)
    return false;
  });
  $("#change_step3").live("click", function() {
    $container.cycle(1)
    return false;
  });
  $("#faq h3, #vod-info-wrap h3").live("click", function() {
    
    id = $(this).attr('id')
    content = id.replace('-title', '')
    here = $(this)
    $("#"+content).slideToggle('slow', function() {
        if($(this).is(':visible'))
        {
          $(here).removeClass('close')
        }
        else
        {
          $(here).addClass('close')
        }
      });
    return false;
  });
  $(".more").live("click", function() {
    
    parent = $(this)
    id = $(this).attr('id')
    content = id.replace('-title-more', '')  
    here_id = content+"-title"
    here = $("#"+here_id)
    $("#"+content).slideDown('slow', function() {
      $(here).removeClass('close')
    });
    if($(this).hasClass("tab1") || $(this).hasClass("tab2") || $(this).hasClass("tab3"))
    {
      if($(this).hasClass("tab1"))
      {
        title = "#tab1-title"
        id="#tab1"
      }
      else if($(this).hasClass("tab2"))
      {
        title = "#tab2-title"
        id="#tab2"
      }
      else
      {
        title = "#tab3-title"
        id="#tab3"
      }
      $('.available').removeClass('active')
      $(title).addClass('active')
      $('.carousel-wrap').hide()
      $(id).show()
    }
    goToByScroll(here_id); //to do
    return false;
  });
  $(".available").live("click", function() {
    id = $(this).attr('id')
    $('.available').removeClass('active')
    $(this).addClass('active')
    content = id.replace('-title', '')
    $('.carousel-wrap').hide()
    $("#"+content).show()
    return false;
  });
  //verimatrix
  /*
  function Unload()
  {
      ViewRightControl.Close();
      ViewRightControl.UnLoad();
  }
  function Resize()
  {
      if (/MSIE (\d+\.\d+);/.test(navigator.userAgent))
      {
  		document.getElementById('ViewRightControl').style.width = 640 * (document.body.offsetWidth / window.screen.width);
  		document.getElementById('ViewRightControl').style.height = 360 * (document.body.offsetHeight / window.screen.height);
  		document.getElementById('OverlayText').style.top = -180 * (document.body.offsetHeight / window.screen.height);
      }
      else
      {
          document.getElementById('ViewRightControl').style.width = (640 * (window.innerWidth / window.screen.width)) + 'px';
          document.getElementById('ViewRightControl').style.height = (360 * (window.innerHeight / window.screen.height)) + 'px';
  		document.getElementById('OverlayText').style.top = (-180 * (window.innerHeight / window.screen.height)) + 'px';
  	}
  }
  function UpdateReturnStatus(retVal)
  {
  	document.getElementById("returnStatus").innerHTML = retVal;
  }
  function Open(mrl)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.Open(mrl, false));
  }
  function Play()
  {
  	UpdateReturnStatus("--");
      UpdateReturnStatus(ViewRightControl.Play());
  }
  function Pause()
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.Pause());
  }
  function Close()
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.Close());
  }
  function Rewind()
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.Rewind());
  }
  function FastForward()
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.FastForward());
  }
  function SetPosition(position)
  {
  	UpdateReturnStatus("--");
  	if(ViewRightControl.GetMediaQualityMetricHTTPLiveStreamingIsVOD() || !document.getElementById('adjustForTimeShift').checked)
  	{
  		UpdateReturnStatus(ViewRightControl.SetPosition(position));
  	}
  	else
  	{
  		var length = ViewRightControl.GetContentLength();
  		UpdateReturnStatus(ViewRightControl.SetPosition(length-position));
  	}
  }
  function GetPosition()
  {
  	UpdateReturnStatus("--");

  	var position = ViewRightControl.GetPosition();
  	if(ViewRightControl.GetMediaQualityMetricHTTPLiveStreamingIsVOD() || !document.getElementById('adjustForTimeShift').checked)
  	{
  		document.getElementById('gPositionField').value = position;
  	}
  	else
  	{
  		var length = ViewRightControl.GetContentLength();
  		document.getElementById('gPositionField').value = length-position;
  	}
  }
  function GetContentLength()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('ContentLengthField').value = ViewRightControl.GetContentLength();	
  }
  function GetState()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getStateField').value = ViewRightControl.GetState();
  }
  function SetAspectRatio(aspect)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetAspectRatio(aspect));
  }
  function GetAspectRatio()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('AspectRatioField').value = ViewRightControl.GetAspectRatio();
  }
  function IsMediaSecure()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('SecureMediaField').value = ViewRightControl.IsMediaSecure();
  }                                                                                         
  function IsMediaSeekable()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('MediaSeekField').value = ViewRightControl.IsMediaSeekable();
  }
  function IsFullscreen()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('FullScreenField').value = ViewRightControl.IsFullscreen();
  }
  function IsMuted()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('MutedField').value = ViewRightControl.IsMuted();
  }
  function SetClosedCaption(setcc)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetClosedCaption(setcc));
  }
  function GetClosedCaption()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getccField').value = ViewRightControl.GetClosedCaption();
  }
  function GetMediaQualityMetricContinuityCounter()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getMediaQualityCounterField').value = ViewRightControl.GetMediaQualityMetricContinuityCounter();
  }
  function GetMediaQualityMetricFramesDropped()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getMediaQualityFrameDropField').value = ViewRightControl.GetMediaQualityMetricFramesDropped();
  }
  function GetMediaQualityMetricAvgFrameRate()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getMediaQualityFrameRateField').value = ViewRightControl.GetMediaQualityMetricAvgFrameRate();
  }
  function SetVolume(volume)
  {
  	UpdateReturnStatus(ViewRightControl.SetVolume(volume));
  }
  function GetVolume()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getVolumeField').value = ViewRightControl.GetVolume();
  }
  function MuteOnOff()
  {
    if (ViewRightControl.IsMuted())
    {
      document.getElementById("muteon_off").innerHTML = "Mute";
      UpdateReturnStatus(ViewRightControl.SetMute(0));
    }
    else
    {
      document.getElementById("muteon_off").innerHTML = "Unmute";
      UpdateReturnStatus(ViewRightControl.SetMute(1));
    }
  }
  function FullscreenOnOff()
  {
    if (ViewRightControl.IsFullscreen())
    {
      UpdateReturnStatus(ViewRightControl.Fullscreen(0));
    }
    else
    {
      UpdateReturnStatus(ViewRightControl.Fullscreen(1));
    }
  }
  function GetQualityMetrics()
  {
  	var plrate = ViewRightControl.GetMediaQualityMetricHTTPLiveStreamingPlaylistRate();
  	var dlrate = ViewRightControl.GetMediaQualityMetricHTTPLiveStreamingDownloadRate();
  	if(plrate == 3 && dlrate == 3) // InvalidState
  	{
  		plrate = "--";
  		dlrate = "--";
  	}
  	document.getElementById('plrate').innerHTML = plrate;
  	document.getElementById('dlrate').innerHTML = dlrate;
  }
  function GetClientID()
  {
    var id;
    id = ViewRightControl.GetClientID();
    document.getElementById('currentClientID').innerHTML = id;
  }
  function GetVersion()
  {
    var id;
    id = ViewRightControl.GetVersion();
    document.getElementById('currentVersion').innerHTML = id;
  }
  function GetSDKVersion()
  {
    var id;
    id = ViewRightControl.GetSDKVersion();
    document.getElementById('currentSDKVersion').innerHTML = id;
  }
  function UpdatePlayerExceptions()
  {
      var exceptionCode = ViewRightControl.GetExceptionCode();
  	if(exceptionCode != -1)
  	{
  		document.getElementById("exceptionLine").innerHTML = "<b>Startup Exception:</b> " + exceptionCode;
  	}
  }
  function UpdatePlayerStatus()
  {
      var statusString = "Unknown";
      var statusCode = ViewRightControl.GetStatusCode(); 
      if (statusCode == 0)
          statusString = "<font color='red'>Uninitialized</font>";
      else if (statusCode == 1)
          statusString = "<font color='yellow'>Idle</font>";
      else if (statusCode == 2)
          statusString = "<font color='yellow'>Opening</font>";
      else if (statusCode == 3)
          statusString = "<font color='orange'>Buffering</font>";
      else if (statusCode == 4)
          statusString = "<font color='lightgreen'>Playing</font>";
      else if (statusCode == 5)
          statusString = "Stopped";
      else if (statusCode == 6)
          statusString = "<font color='blue'>Paused</font>";
      else if (statusCode == 7)
          statusString = "Fast Forwarding";
      else if (statusCode == 8)
          statusString = "Rewinding";
      else if (statusCode == 9)
          statusString = "Slow Motion";
      else if (statusCode == 10)
          statusString = "Closing";
      else if (statusCode == 11)
          statusString = "Shutting Down";

      document.getElementById("playerStatus").innerHTML = statusString;
  }
  function UpdateVCASReturnStatus()
  {
      var status = ViewRightControl.GetVCASStatusCode();

      if (status == -1)
          exceptionString = "<font color='red'>Unknown error</font>";
      else if (status == 0)
          exceptionString = "<font color='lightgreen'>Success</font>";
      else if (status == 1)
          exceptionString = "<font color='red'>No connection</font>";
      else if (status == 2)
          exceptionString = "<font color='red'>General error</font>";
      else if (status == 3)
          exceptionString = "<font color='red'>Bad memory allocation</font>";
      else if (status == 4)
          exceptionString = "<font color='red'>Bad random number generated</font>";
      else if (status == 5)
          exceptionString = "<font color='red'>Bad URL</font>";
      else if (status == 6)
          exceptionString = "<font color='red'>Bad reply</font>";
      else if (status == 7)
          exceptionString = "<font color='red'>Bad reply moved</font>";
      else if (status == 8)
          exceptionString = "<font color='red'>Error in verifying certificate chain</font>";        
      else if (status == 9)
          exceptionString = "<font color='red'>Error in creating key pair</font>";
      else if (status == 10)
          exceptionString = "<font color='red'>Not entitled</font>";
      else if (status == 11)
          exceptionString = "<font color='red'>Error creating store file</font>";
      else if (status == 12)
          exceptionString = "<font color='red'>Error writing to store file</font>";
      else if (status == 13)
          exceptionString = "<font color='red'>Error reading from store file</font>";
      else if (status == 14)
          exceptionString = "<font color='red'>Failed store file integrity check</font>";
      else if (status == 15)
          exceptionString = "<font color='red'>Store file does not exist</font>";
      else if (status == 16)
          exceptionString = "<font color='red'>Bad certificate</font>";
      else if (status == 17)
          exceptionString = "<font color='red'>Bad INI file</font>";
      else if (status == 18)
          exceptionString = "<font color='red'>Bad private key</font>";
      else if (status == 19)
          exceptionString = "<font color='red'>Error in converting PEM to X509</font>";
      else if (status == 20)
          exceptionString = "<font color='red'>Bad public encryption</font>";
      else if (status == 21)
          exceptionString = "<font color='red'>Invalid add X509 entry</font>";
      else if (status == 22)
          exceptionString = "<font color='red'>Invalid add X509 subject</font>";
      else if (status == 23)
          exceptionString = "<font color='red'>Invalid X509 sign</font>";
      else if (status == 24)
          exceptionString = "<font color='red'>Can't retrieve boot</font>";
      else if (status == 25)
          exceptionString = "<font color='red'>Can't provision</font>";
      else if (status == 26)
          exceptionString = "<font color='red'>Invalid arguments</font>";
      else if (status == 27)
          exceptionString = "<font color='red'>Invalid key generation</font>";
      else if (status == 28)
          exceptionString = "<font color='red'>Not provisioned</font>";
      else if (status == 29)
          exceptionString = "<font color='red'>Communication object not initialized</font>";
      else if (status == 30)
          exceptionString = "<font color='red'>No OTT signature</font>";
      else if (status == 31)
          exceptionString = "<font color='red'>Invalid OTT signature</font>";
      else if (status == 32)
          exceptionString = "<font color='red'>Key file not entitled</font>";
      else if (status == 33)
          exceptionString = "<font color='red'>Certificate expired</font>";
      else if (status == 34)
          exceptionString = "<font color='red'>Integrity check failed</font>";
      else if (status == 35)
          exceptionString = "<font color='red'>Security error</font>";

      document.getElementById("vcasStatus").innerHTML = exceptionString;
  }
  function GetVCASInfo()
  {
    var status = eval("(" + ViewRightControl.GetClientStatus(1) + ")");

    if(status.expirationtime<10000000000)
    status.expirationtime *= 1000;

    var epochDate = new Date();
    epochDate.setTime(status.expirationtime);
    document.getElementById('expirationtime').innerHTML = epochDate;
    document.getElementById('isprovisioned').innerHTML = status.isprovisioned;       
    document.getElementById('isdeviceprovisioned').innerHTML = ViewRightControl.IsDeviceProvisioned();
    if (document.getElementById('companyname').value == "")
      document.getElementById('companyname').value = status.companyname;
    if (document.getElementById('hostport').value == "")
      document.getElementById('hostport').value = status.hostport;  
  }
  function SetVCASInfo(companyname, hostport)
  {
  	document.getElementById('companyname').value = companyname;
  	document.getElementById('hostport').value = hostport;
  }
  function save(persistFlag)
  {
      var companyname = document.getElementById('companyname').value;
      var vcasHost = document.getElementById('hostport').value;

      UpdateReturnStatus(ViewRightControl.RegisterBootServer(vcasHost, companyname, persistFlag));

      GetVCASInfo();
  }
  function SetSRTSubtitle(setcc)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetSRTSubtitle(setcc, true));
  }
  function SetSRTInfo(srt)
  {
  	document.getElementById('setSRTField').value = srt;
  }
  function SetSRTSubtitleOff()
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetSRTSubtitle("", false));
  }
  function GetSRTSubtitle()
  {
  	UpdateReturnStatus("--");
  	document.getElementById('getSRTField').value = ViewRightControl.GetSRTSubtitle();
  }
  function SetDesiredAudioLanguage(lang) 
  { 
  	UpdateReturnStatus("--"); 
  	UpdateReturnStatus(ViewRightControl.SetDesiredAudioLanguage(lang)); 
  } 
  function GetDesiredAudioLanguage() 
  { 
  	document.getElementById('getDesiredAudioLanguage').value = ViewRightControl.GetDesiredAudioLanguage(); 
  }

  function SetAssumedBandwidth(bandwidth)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetAssumedBandwidth(bandwidth));
  }

  function ResizeWindow(width, height)
  {
  	var overlayPos = -height / 2;
      if (/MSIE (\d+\.\d+);/.test(navigator.userAgent))
      {
  		document.getElementById('ViewRightControl').style.width = width * (document.body.offsetWidth / window.screen.width);
  		document.getElementById('ViewRightControl').style.height = height * (document.body.offsetHeight / window.screen.height);
  		document.getElementById('OverlayText').style.top = overlayPos * (document.body.offsetHeight / window.screen.height);
      }
      else
      {
          document.getElementById('ViewRightControl').style.width = (width * (window.innerWidth / window.screen.width)) + 'px';
          document.getElementById('ViewRightControl').style.height = (height * (window.innerHeight / window.screen.height)) + 'px';
          document.getElementById('OverlayText').style.top = (overlayPos * (window.innerHeight / window.screen.height)) + 'px';
      }
  }
  function OverlayControlEnable()
  {
    if (ViewRightControl.IsOverlayControlEnabled())
    {
      document.getElementById("overlayon_off").innerHTML = "Overlay Off";
      UpdateReturnStatus(ViewRightControl.SetOverlayControlEnable(0, 100));
    }
    else
    {
      document.getElementById("overlayon_off").innerHTML = "Overlay On";
      UpdateReturnStatus(ViewRightControl.SetOverlayControlEnable(1, 100));
    }
  }
  function SetOverlayDateText()
  {
  	var d = new Date();
  	var textField ;
  	var resultOfMod = d.getSeconds()%5;
  	var plrate = ViewRightControl.GetMediaQualityMetricHTTPLiveStreamingPlaylistRate();
  	var dlrate = ViewRightControl.GetMediaQualityMetricHTTPLiveStreamingDownloadRate();
  	if(resultOfMod != 0)
  	{
  		textField  = 'CurrentTime: ' + d + '\r\nPlaylist/DL Rate: ' + plrate + '/' + dlrate + '\r\nLine3'+ '\r\nLine4';
  		ViewRightControl.SetOverlayControlText(textField,12,175,238,238,0);
  	}
  	else
  	{
  		ViewRightControl.SetOverlayControlText("",11,238,175,238,0);
  	}
  }
  function SetSkin(skinurl)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetOverlayControlSkin(skinurl));
  }
  function SetBufferingAnimation(setcc)
  {
  	UpdateReturnStatus("--");
  	UpdateReturnStatus(ViewRightControl.SetBufferingAnimation(setcc, true));
  }*/
});