$(function() {
  // Ajax history, only works on the product.reviews for now
  $(".mail_copy").live("click", function() {
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
  
  $(".news_x").live("click", function() {
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
  var options_norm = {
    success: show_add_norm
  }
  function show_add_norm(responseText, statusText){
    if(jQuery.trim(statusText) == "success"){
      item = html_item.html(responseText);
    }
    else
    {
      html_item.html(content);
    }
  };
  
  $(".add_norm").live("click", function() {
    loader = 'ajax-loader.gif';
    $(this).parent().ajaxSubmit(options_norm);
    html_item = $(this).parent().parent().parent().parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<div style='height:42px'><img src='/images/"+loader+"'/></div>");
    return false; // prevent default behaviour
  });
  

  $(".add_adult").live("click", function() {
    
    html_item = $(this).parent().parent().parent().parent();
    norm = $(this).parent().children('#norm').attr('value')
    adult = $(this).parent().children('#adult').attr('value')
    norm --;
    adult ++
    form = $(this).parent()
    content = html_item.html();
    if ($(this).hasClass('empty'))
    {
      confirm_title = $('#rotation').html();
      confirm_title = confirm_title.replace('[norm]',norm)
      confirm_title = confirm_title.replace('[adult]',adult)
      
      if(confirm(confirm_title))
      {
        sent_adult_rotation(form,html_item);  
      }
    }
    else
    {
      sent_adult_rotation( form,html_item);  
    }
    
    return false;
  });

  function sent_adult_rotation(form, html_item)
  {
    $(form).ajaxSubmit(options_norm);
    loader = 'ajax-loader.gif';
    html_item.html("<div style='height:42px'><img src='/images/"+loader+"'/></div>");
    return false; // prevent default behaviour
    
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
  var options2 = {
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
    $('#new_suspension').html("<div style='height:32px'><img src='/images/"+loader+"'/></div>")
    $('#suspend-abonament form').ajaxSubmit(options);
    return false; // prevent default behaviour
  });
  
  $('#edit_nickname #bt_valid').live("click", function(){
    loader = 'ajax-loader.gif';
    $('.bouton_probleme').html("<div style='height:42px'><img src='/images/"+loader+"'/></div>")
    $('.content form').ajaxSubmit(options);
    return false; // prevent default behaviour
  });
  /*$('#new_avatar #bt_valid').live("click", function(){
    loader = 'ajax-loader.gif';
    $('.content form').submit();
    $('.bouton_probleme').html("<div style='height:42px'><img src='/images/"+loader+"'/></div>")
  
  });*/
  
  function param(name,url)
  {
    var results = new RegExp('[\\?&]' + name + '=([^&#]*)').exec(url)
    return results[1] || 0;
  }
});
