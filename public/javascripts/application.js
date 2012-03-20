$.ajaxSettings.accepts._default = "text/javascript, text/html, application/xml, text/xml, */*";
$(function() {
  search_text = $('#search-field').attr('value');
  $('#search-field').live('focus', function(){
    if($('#search-field').attr('value') == search_text){
      $('#search-field').val('');
    }
  });

  $('#search-field').live('blur', function(){
    if($('#search-field').attr('value') == ''){
      $('#search-field').val(search_text);
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

  $(".datepicker").datepicker({
    disabled: true,
    showButtonPanel: false,
    firstDay: 1,
    dateFormat: 'dd-mm-yy',
    onSelect: function(dateText, inst) { 
      d=new Date();
      month = (d.getMonth()+1);
      if(parseInt(month)<10)
      {
        month = new String('0'+month)
      }
      day = d.getDate()
      if(parseInt(day)<10)
      {
        day = new String('0'+day)
      }
      
      if (dateText == day+"-"+month+"-"+d.getFullYear())
      {
        limit = 0
        h = d.getHours()
        if(parseInt(h)==9)
        {
          limit = 4
        }
        else if (parseInt(h)== 10)
        {
          limit = 6
        }  
        else if (parseInt(h)== 11)
        {
            limit = 8
        }
        else if (parseInt(h)== 12)
        {
            limit = 10
        }
        else if (parseInt(h)== 13)
        {
            limit = 12
        }
        else if (parseInt(h)== 14)
        {
            limit = 14
        }
        else if (parseInt(h)== 15)
        {
            limit = 16
        }
        else if (parseInt(h)== 16)
        {
            limit = 18
        }
        $.each($('#phone_request_hour').children(), function (){
          if(parseInt($(this).attr('value'))<=limit)
          {
            $(this).attr('disabled','disabled')
            $(this).hide()
          }
        })
        $("select#phone_request_hour option[selected]").removeAttr("selected");
        $("select#phone_request_hour option[value='']").attr("selected", "selected");
      }
      else
      {
        $.each($('#phone_request_hour').children(), function (){
            $(this).show()
            $(this).removeAttr('disabled');
        })
      }
    },
    minDate: new Date()});

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