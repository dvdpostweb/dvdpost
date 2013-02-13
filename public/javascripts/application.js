$.ajaxSettings.accepts._default = "text/javascript, text/html, application/xml, text/xml, */*";
$(function() {
  search_init = $('#search_text').html();
  $('#search-field').live('focus', function(){
    if($('#search-field').attr('value') == search_init){
      $('#search-field').val('');
    }
  });

  $('#search-field').live('blur', function(){
    if($('#search-field').attr('value') == ''){
      $('#search-field').val(search_init);
    }
  });
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
  

  $(".streaming_action").live("click", function() {
    wishlist_item = $(this);
    jQuery.facebox(function() {
      $.getScript(wishlist_item.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });

  $(".face_img").live("click", function() {
    url = $(this);
    jQuery.facebox(function() {
      data = "<img src='"+url.attr('href')+"' width='800' height='600' />";
      jQuery.facebox(data);
    });
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
  $('#search_filter').live('click',function(){
    $('#search_filter_detail').toggle()
    return false;
  });

  $('ul#search_filter_detail').live('mouseout',function(){
    $('#search_filter_detail').hide()
  });

  $('#search_filter_detail li, ul#search_filter_detail').live('mouseover',function(){
    $('#search_filter_detail').show()
  });

  $('#filter_button').live('mouseover',function(){
    $('#search_filter_detail').hide()
  });
  $('.filter_input').live('click',function(){
    $('#search_filter_detail').hide()
    $('#search_filter').html($(this).parent().children().children().html())
  });
  $('#codePromo, #codePromo2').live('click', function(){
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.getScript(url, function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });
  $('#no_tx').live('click', function(){
    jQuery(document).trigger('close.facebox')
    return false;
  })
  if ($('.action_face').html()!=undefined)
  {
    if($('.action_face').attr('id') == 'newsletters')
    {
      $.facebox.settings.opacity = 0.4; 
      $.facebox.settings.modal = true;
    }
    jQuery.facebox(function() {
      set_page($('.action_face').html())
      $.getScript($('.action_face').html(), function(data) {
        jQuery.facebox(data);
      });
    });
  }
  $('#later').live('click',function(){
    h = document.URL
    h = h + (h.indexOf('?') != -1 ? "&later=1" : "?later=1");
    window.location = h
    return false
  });
  var options_norm = {
    success: show_add_norm,
  }
  function show_add_norm(responseText, statusText){
    if(jQuery.trim(statusText) == "success"){
      if(responseText.indexOf('http')>=0)
      {
        $(location).attr('href', responseText);
      }
      else
      {
        html_item.html(responseText);
      }
    }
    else
    {
      html_item.html(content);
    }
  };
  
  $(".public_promo_btn").live("click", function() {
    if ($("#promotion").val()!=""){
      loader = 'ajax-loader.gif';
      $("#public_promo").ajaxSubmit(options_norm);
      html_item =  $("#public_promo #status")
      content = html_item.html();
      loader = 'ajax-loader.gif';
      html_item.html("<div style='height:42px'><img src='/images/"+loader+"'/></div>");
    }
    else
    {
      html_item =  $("#public_promo #status").html('')
    }
      return false; // prevent default behaviour
    
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
function set_page(url)
{
  recommendation = getParameterByName('recommendation')
  url = url.replace('http://private.dvdpost.dev','')
  url = url.replace('http://public.dvdpost.dev','')
  url = url.replace('http://staging.private.dvdpost.com','')
  url = url.replace('http://staging.public.dvdpost.com','')
  url = url.replace('http://beta.dvdpost.com','')
  url = url.replace('http://beta.public.dvdpost.com','')
  url = url.replace('http://private.dvdpost.com','')
  url = url.replace('http://public.dvdpost.com','')
  if (recommendation.length > 0)
  {
    url = url + (url.indexOf('?') != -1 ? "&recommendation="+recommendation : "?recommendation="+recommendation);
  }
  _gaq.push(['._trackPageview', url]); 
  _gaq.push(['b._trackPageview', url]); 
}
function send_event(category, action,label,value)
{
  if(value == '')
  {
    _gaq.push(['._trackEvent', category, action, label])
    _gaq.push(['b._trackEvent', category, action, label])
  }
  else
  {
    _gaq.push(['._trackEvent', category, action, label+value])
    _gaq.push(['b._trackEvent', category, action, label+value])
  }
}
function getParameterByName(name)
{
  name = name.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
  var regexS = "[\\?&]" + name + "=([^&#]*)";
  var regex = new RegExp(regexS);
  var results = regex.exec(window.location.search);
  if(results == null)
    return "";
  else
    return decodeURIComponent(results[1].replace(/\+/g, " "));
}
$('#nav3').live('mouseover',function(){
  $('.dropdown').show()
})
$('.dropdown').live('mouseleave',function(){
  $('.dropdown').hide()
})
// When I say html I really mean script for rails
$.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;

