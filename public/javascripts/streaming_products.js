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
    $('#player').html('')
    $('#presentation').html("<div style='height:389px'><div class='load'><img src='/images/"+loader+"'/></div></div>")
    $(this).hide()
    $.ajax({
      dataType: 'html',
      url: $(this).attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        $('#flow').html(data);
        $('#presentation').html('')
        $('.qualityvod').show()
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
});