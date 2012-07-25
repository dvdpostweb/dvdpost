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