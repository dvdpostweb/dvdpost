$(function() {
  // Ajax history, only works on the product.reviews for now

  $(".suppendre_newsletter").live("click", function() {
    url = $(this).attr('href');
    html_item = $(this).parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<img src='/images/"+loader+"'/>");
    $.ajax({
      url: url,
      type: 'POST',
      data: {},
      success: function(data) {
        item = html_item.html(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $(".suppendre_newsletter_parnter").live("click", function() {
    url = $(this).attr('href');
    html_item = $(this).parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<img src='/images/"+loader+"'/>");
    $.ajax({
      url: url,
      type: 'POST',
      data: {},
      success: function(data) {
        item = html_item.html(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $(".add_normal").live("click", function() {
    url = $(this).attr('href');
    html_item = $(this).parent().parent().parent().parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<div style='height:42px'><img src='/images/"+loader+"'/></div>");
    $.ajax({
      url: url,
      type: 'POST',
      data: {},
      success: function(data) {
        item = html_item.replaceWith(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $(".add_adult").live("click", function() {
    url = $(this).attr('href');
    html_item = $(this).parent().parent().parent().parent();
    norm = param('norm',url)
    adult = param('adult',url)
    norm --;
    adult ++
    
    content = html_item.html();
    loader = 'ajax-loader.gif';
    load = "<div style='height:42px'><img src='/images/"+loader+"'/></div>";
    if ($(this).hasClass('empty'))
    {
      confirm_title = $('#rotation').html();
      confirm_title = confirm_title.replace('[norm]',norm)
      confirm_title = confirm_title.replace('[adult]',adult)
      
      if(confirm(confirm_title))
      {
        sent_adult_rotation(url, html_item, content, load);  
      }
    }
    else
    {
      sent_adult_rotation(url, html_item, content, load);  
    }
    
    return false;
  });

  function sent_adult_rotation(url, html_item, content, load)
  {
    html_item.html(load)
    $.ajax({
      url: url,
      type: 'POST',
      data: {},
      success: function(data) {
        item = html_item.replaceWith(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    
  }
  $(".modification_account").live("click", function() {
    url = $(this);
    jQuery.facebox(function() {
      $.getScript(url.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });
  $(".modification_address").live("click", function() {
    url = $(this);
    jQuery.facebox(function() {
      $.getScript(url.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });
  var options = {
    success: showResponse  // post-submit callback
  };
  $('#submit_account').live("click", function(){
    loader = 'ajax-loader.gif';
    $('.bouton_probleme').html("<div style='height:42px'><img src='/images/"+loader+"'/></div>")
    $('.content form').ajaxSubmit(options);
    return false; // prevent default behaviour
  });
  $('#submit_address').live("click", function(){
    loader = 'ajax-loader.gif';
    $('.bouton_probleme').html("<div style='height:42px'><img src='/images/"+loader+"'/></div>")
    $('.content form').ajaxSubmit(options);
    return false; // prevent default behaviour
  });

  // post-submit callback
  function showResponse(responseText, statusText)  {
    if(jQuery.trim(responseText) == "Success"){
      $.facebox.close;
      window.location.href = window.location.pathname;
    } else {
      $('.content').html(responseText);
    }
  }
  $('#change_password').live("click", function(){

    $('#password').html('<input type="password" value="" size="30" name="customer[clear_pwd]" id="customer_clear_pwd">')
    $('#password_confirmation').show();
    $(this).hide();
    return false; // prevent default behaviour
  });

  $(".suppendre").live("click", function() {
    url = $(this);
    jQuery.facebox(function() {
      $.getScript(url.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });

  $('#new_suspension').live("click", function(){
    loader = 'ajax-loader.gif';
    $('#new_suspension').html("<div style='height:42px'><img src='/images/"+loader+"'/></div>")
    $('#suspend-abonament form').ajaxSubmit(options);
    return false; // prevent default behaviour
  });
  function param(name,url)
  {
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(url)
    return results[1] || 0;
  }
});
