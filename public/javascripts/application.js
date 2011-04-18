$.ajaxSettings.accepts._default = "text/javascript, text/html, application/xml, text/xml, */*";
$(function() {
  // Enable fragmetChange. This will allow us to put ajax into browser history
  $.fragmentChange(true);

  // hides the slickbox as soon as the DOM is ready
  // (a little sooner than page load)
  $('#lang-box').hide();

  // toggles the slickbox on clicking the noted link
  $('a#lang').click(function() {
    $('#lang-box').toggle(50);
    return false;
  });

  $("#indicator #n7").click(function() {
    $("#indicator-tips").toggle(0);
    indicator_url = $(this).attr('href')
    $.getScript(indicator_url);
    len = indicator_url.length;
    if(indicator_url.charAt((len-1))==1)
    {
      indicator_url = indicator_url.replace('status=1','status=0')
    }
    else
    {
      indicator_url = indicator_url.replace('status=0','status=1')
    }
    $(this).attr('href',indicator_url)
    return false;
  });

  $("#indicator-tips").click(function() {
    $("#indicator-tips").hide();
    $.getScript($("#close a").attr('href'));
    return false;
  });

  $(".datepicker").datepicker({
    disabled: true,
    showButtonPanel: false 
  });

  $(".streaming_action").live("click", function() {
    wishlist_item = $(this);
    jQuery.facebox(function() {
      $.getScript(wishlist_item.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });

  $("#tops, #categories").live("click", function() {
    
    id = $(this).attr('id')
    list = "#"+id+"_list"
    $(list).toggle();
    $.getScript($(this).attr('href'));
    if($(list).is(':hidden') == true)
    {
      $(this).removeClass('active')
      url = $(this).attr('href').replace('close', 'open')
      $(this).attr('href',url)
    }
    else
    {
      $(this).addClass('active')
      url = $(this).attr('href').replace('open', 'close')
      $(this).attr('href',url)
      menus = ["tops","categories"]
      for(var i=0; i < menus.length;i++)
      {
        if(menus[i] != id)
        {
          list = "#"+menus[i]+"_list"
          $("#"+menus[i]).removeClass('active')
          $(list).hide()
        }
      }
    }
    return false;
  });

$("#condition_promo").live("click", function() {
  a = $(this);
  jQuery.facebox(function() {
    $.getScript(a.attr('href'), function(data) {
      jQuery.facebox(data);
    });
  });
  return false;
});

});
// Always send the authenticity_token with ajax
$(document).ajaxSend(function(event, request, settings) {
    if ( settings.type.toLowerCase() == 'post' || settings.type.toLowerCase() == 'delete' ) {
        settings.data = (settings.data ? settings.data + "&" : "")
                + "authenticity_token=" + encodeURIComponent( AUTH_TOKEN );
        request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
    }
});

// When I say html I really mean script for rails
$.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;