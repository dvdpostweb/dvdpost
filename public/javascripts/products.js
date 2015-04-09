$(function() {
  // Ajax history, only works on the product.reviews for now
  var options_review = {
    success: show_review,
    dataType: 'html'
  }  
  if(($('#image_5').attr('src')!=undefined))
  {
  var img = new Image();
  img.onload = function() {
     height_im = this.height
     if(height_im <= 3)
     {
       $('#thumbs-wrap').hide()
     }
  }
  img.src = $('#image_1').attr('src');
  }
  
  function show_review(responseText, statusText){
    if(jQuery.trim(statusText) == "success"){
      item = html_item.html(responseText);
    }
    else
    {
      html_item.html(content);
    }
  };
  $('.normal .preview_box img').click(function() {
    url = $(this).attr('src')
    url = url.replace('screenshots/small/', 'screenshots/big/')
    open_image(url)
  });
  $(window).keydown(function(e){
    if ($('#big_image').is(":visible"))
    {
  		switch (e.keyCode) {
  			case 37: // flèche gauche
  				next_prev('minder')
  				break;
  			case 39: // flèche droite
  				next_prev('plus')
  				break;
  		}
  	}
  });
  $('.next_button, .prev_button').live("click", function() {
    if($(this).hasClass('next_button'))
    {
      next_prev('plus')
    }
    else
    {
      next_prev('minder')
    }
  });
  function next_prev(operation)
  {
    url = $('#big_image').attr('src')
    l = url.length
    ext = url.substr((l-5),5)
    n = url.substr((l-5),1)
    if(operation == 'plus')
    {
      n = parseInt(n)+1
    }
    else
    {
      n = parseInt(n)-1
    }
    if( n>6 )
    {
      n=1
    }
    if(n<1)
    {
      n=6
    }
    url = url.replace(ext,n+'.jpg')
    open_image(url)
  }
  function open_image(url)
  {
    var img = new Image();
    img.onload = function() {
       height_im = this.height
       width_im = this.width
       if(height_im > 3)
       {
         img = "<div style='width:"+width_im+"px; height:"+height_im+"px; text-align:center;position:relative;margin: 0 0 15px;'><div class='prev_button' style='height:"+height_im+"px'><div class='image_prev'></div></div><div class='next_button' style='height:"+height_im+"px'><div class='image_next'></div>     </div>    <img src='"+url+"' id='big_image'/></div>"
         jQuery.facebox(img);
         
       }
    }
    img.src = url;
    set_page(url)
  }
  $("#tab-content-movie #sort").live("change", function() {
    loader = 'ajax-loader.gif';
    $(this).parent().ajaxSubmit(options_review);
    html_item = $("#tab-content-movie .content_item");
    content = html_item.html();
    $(this).parent().html("<div style='height:22px'><img src='/images/"+loader+"'/></div>");
    return false; // prevent default behaviour
  });
  
  
  $("#tab1 #pagination a").live("click", function() {
    $.setFragment({ reviews_page: $.queryString(this.href).reviews_page })
  });

  $("#tab-content-movie #pagination a, #trailer_pagination a, .linkallversions a").live("click", function() {
    html_item = $(this);
    content = html_item.parent().html();
    html_item.parent().html("Loading...");
    root_item = html_item.parent().parent().parent();
    
    set_page(html_item.attr('href'))
    $.ajax({dataType: 'html',
      url: html_item.attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        root_item.html(data);
      },
      error: function() {
        html_item.parent().html(content);
      }
    });
    return false;
  });
  $(".linkallversions a").live("click", function() {
    html_item = $(this);
    content = html_item.html();
    html_item.html("Loading...");
    root_item = $('#content_trailer');
    
    set_page(html_item.attr('href'))
    $.ajax({dataType: 'html',
      url: html_item.attr('href'),
      type: 'GET',
      data: {},
      success: function(data) {
        root_item.html(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $(".stars .star, .comments .star, .rating .star").live("click", function() {
    url = $(this).parent().attr('href');
    html_item = $(this).parent().parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    if ($(this).attr('src').match(/black-star-/i)){
      loader = 'black-'+loader;
    }
    html_item.html("<div style='height:19px'><img src='/images/"+loader+"'/></div>");
    set_page(url)
    var regex = new RegExp(".*/products/([0-9]*).*value=([0-9])");
    
    $.ajax({dataType: 'html',
      url: url,
      type: 'POST',
      data: {},
      success: function(data) {
        $('.tooltip_items').hide()
        if (url.match(/replace=homepage/)){
          if(data.match(/user-movies-wrap/))
          {
            html_item.parent().parent().parent().parent().replaceWith(data);  
          }
          else
          {
            html_item.parent().parent().parent().replaceWith(data);  
          }
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

  $(".stars .star, .comments .star, .rating .star").live("mouseover", function(){
    data = $(this).attr('id').replace('star_','').split('_');
    product_id = data[0];
    rating_value = data[1];

    image = 'star-voted-';
    for(var i=1; i<=5; i++)
    {
      if(i <= rating_value){
        full_image = image+'on';
      }else{
        full_image = image+'off';
      }
      $('#star_'+product_id+"_"+i).attr('src', '/images/'+full_image+'.png?t=1');
    }
  });

  $(".stars .star, .comments .star, .rating .star").live("mouseout", function() {
    product_id = $(this).attr('id').replace('star_','').split('_')[0];
    for(var i=1; i<=5; i++)
    {
      image = $('#star_'+product_id+'_'+i);
      image.attr('src','/images/'+image.attr('name'));
    }
  });

  $(".add_to_wishlist_button").live("click", function() {
    wishlist_item = $(this);
    url = wishlist_item.attr('href')
    set_page(url)
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
  
  $("a.btn_remove").live("click", function() {
    html_item = $(this).parent();
    content = html_item.html();
    loader = "ajax-loader.gif";
    if ($(this).attr('href').match(/black/i)){
      loader = 'black-'+loader;
    }
    html_item.html("<div class='load'><img src='/images/"+loader+"' /></div>");
    $.ajax({dataType: 'html',
      url: this.href,
      type: 'DELETE',
      data: {},
      success: function(data) {
        //html_item.replaceWith(data);
      },
      error: function() {
        //html_item.html(content);
      }
    });
    return false;
  });
  
  $(".links a").live("click", function() {
    html_item = $(this).parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<div style='height:15px'><img src='/images/"+loader+"'/></div>");
    set_page(this.href)
    $.ajax({dataType: 'html',
      url: this.href,
      type: 'POST',
      data: {},
      success: function(data) {
        $('.tooltip_items').hide()
        html_item.html(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    
    return false;
  });

  $("#oscars a").click(function() {
    html_item = $('#oscars_text');
    content = html_item.html();
    set_page(this.href)
    $.ajax({
      url: this.href,
      dataType: 'html',
      type: 'GET',
      data: {},
      success: function(data) {
        html_item.html(data);
        $("#oscars").hide();
      },
      error: function() {
        html_item.html(content);
        $("#oscars").hide();
      }
    });
    return false;
  });
  $("#c-members #pagination a").live("click", function() {
    html_item = $(this).parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<div style='height:24px; margin:10px 0 0 0'><img src='/images/"+loader+"'/></div>");
    set_page(this.href)
    $.ajax({
      url: this.href,
      dataType: 'html',
      type: 'GET',
      data: {},
      success: function(data) {
        $('#c-members').html(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $("#c-members #sort").live("change", function() {
    loader = 'ajax-loader.gif';
    $(this).parent().ajaxSubmit(options_review);
    html_item = $("#c-members");
    content = html_item.html();
    $(this).parent().html("<div style='height:22px'><img src='/images/"+loader+"'/></div>");
    return false; // prevent default behaviour
  });

  $("#filters ul li a").live("click", function() {
    $(this).parent().toggleClass('open');
    $(this).parent().find("div").toggle(1);
    return false;
  });

  $("#top10").ready(function() {
    $("#top10 a.t-arrow").toggleClass('open');
  });
  $("#top10 a.t-arrow").live("click", function() {
    $(this).toggleClass('open');
    $(this).parent().find(".top-description").toggle(1);
    return false;
  });

  $('.tabs li').live('click', function(){
    $("#c-members").toggle();
    $("#c-nina").toggle();
    $('#tab1_li a').toggleClass('active');
    $('#tab2_li a').toggleClass('active');
    return false;
  });
  if($('#online #filters').html())
  {
    load_form()
    $('#cl, #film-details, #categories, #studios').delegate('#online #date_filters_year_min, #online  #date_filters_year_max', "change", function(){
      submit_online()
    })
    $('#cl, #film-details, #categories, #studios').delegate('.packages.svod, .packages.tvod', 'click', function(){
      $('#filter_online_form').attr('action', $(this).attr('href'))
      $('.packages').removeClass('current')
      $(this).addClass('current')
      submit_online()
      return false;
    })
    $('#cl, #film-details, #categories, #studios').delegate(".links", "change", function(){
      submit_online()
    })
    $('#cl, #film-details, #categories, #studios').delegate(".links a", "click", function(){
        url = $(this).attr('href');
        html_item = $(this).parent()
        content =  html_item.html()
        loader = 'ajax-loader.gif';
        html_item.html("<img src='/assets/"+loader+"' />");
        $.ajax({dataType: 'html',
          url: url,
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
      })
    /*close thing*/
    $('#cl, #film-details, #categories, #studios').delegate("#close_audience", "click", function() {
      $("#online #audience-slider-range").slider("values", [0,4])
    });
    $('#cl, #film-details').delegate("#close_country", "click", function() {
      $('#online #filters_country_id').val('').trigger('chosen:updated');
      submit_online()
    });
    $('#cl, #film-details, #categories, #studios').delegate("#close_year", "click", function() {
      $("#online #date_filters_year_min").val($("#online #date_filters_year_min option:first").val());
      $("#online #date_filters_year_max").val($("#online #date_filters_year_min option:last").val());
      submit_online()
    });
    /*$('#cl').delegate(".links", "click", function() {
      $('#filters_view_mode').val($(this).attr('data'))
      submit_online()
    })*/
    $('#cl').delegate("#close_ratings", "click", function() {
      $("#online #ratings-slider-range").slider("values", [0,18])
    })
    $('#cl').delegate("#close_audios", "click", function() {
      $('#online #filters_audio').val('audio...').trigger('chosen:updated');
      submit_online()
    })
    $('#cl').delegate("#close_subtitles", "click", function() {
      $('#online #filters_subtitles').val('sub...').trigger('chosen:updated');
      submit_online()
    })
    $('#cl').delegate("#close_category", "click", function() {
      $('#online #filters_category_id').val('').trigger('chosen:updated');
      submit_online()
    })
    $('#cl').delegate("#close_actor", "click", function() {
      $('#filter_online_form').attr('action', $(this).attr('url'))
      submit_online()
    })
    $('#cl').delegate("#close_director", "click", function() {
      $('#filter_online_form').attr('action', $(this).attr('url'))
      submit_online()
    })
    $('#cl').delegate("#close_view_mode", "click", function() {
      $('.links').prop('checked', false);
      submit_online()
    })
    
    $('#cl').delegate("#pagination.deactive a", "click", function() {
      ajax_pagination($(this).attr('href'))
      return false
    })
  }
  $('#carousel-wrap #next,#carousel-wrap .next_page').live('click',function(){
    url = this.href;
    html_item = $('#carousel-wrap');
    content = html_item.html();
    set_page(url)
    $.ajax({dataType: 'html',
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_item.replaceWith(content);
      }
    });
    return false;
  });
  
  $('#carousel-wrap #prev,#carousel-wrap .prev_page').live('click',function(){
    url = this.href;
    html_item = $('#carousel-wrap');
    content = html_item.html();
    set_page(url)
    $.ajax({dataType: 'html',
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_item.replaceWith(content);
      }
    });
    return false;
  });


  $('.title-vod a.next_page').live('click',function(){
    url = this.href;
    html_item = $('.title-vod');
    content = html_item.html()
    set_page(url)
    $.ajax({dataType: 'html',
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_item.replaceWith(content);
      }
    });
    return false;
  });
  
  $('.title-vod a.prev_page').live('click',function(){
    url = this.href;
    html_item = $('.title-vod');
    content = html_item.html()
    set_page(url)
    $.ajax({dataType: 'html',
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_item.replaceWith(content);
      }
    });
    return false;
  });

  $('#about_ppv').live('click', function(){
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.ajax({
          url: url,
          dataType: 'html',
          type: 'GET',
          success: function(data) 
          { 
            set_page(url)
            jQuery.facebox(data); 
          }
        });
    });
    return false;
  });  
  $('.trailer').live('click', function(){
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.ajax({
          url: url,
          dataType: 'html',
          type: 'GET',
          success: function(data) 
          { 
            set_page(url)
            var regex = new RegExp(".*/products/([0-9]*).*");
            jQuery.facebox(data); 
          }
        });
    });
    return false;
  });
  var options = {dataType: 'html'};
  $("#review_submit").live('click',function(){
    value = parseInt($('#review_rating').attr('value'),10);
    if( value == 0 || value > 5 )
    {
      alert($('#popup_rating_error').html())
      return false;
    }
    t=$('#review_text').val()
    i=$('.cover').children().children().attr('src')
    id=$('#review_product_id').html()
    local=$('#review_locale').html()
    title = $('#detail-wrap h2').html()
    f=$('#facebook').attr('checked')?1:0;
    if(f==1)
    {
      postToFeed(t, i, local, id, title, 'www.dvdpost.be' );
    }
    set_page($("#new_review").attr('action'))
    $("#new_review").ajaxSubmit({dataType: 'script'});
    $("#review_submit").parent().html("<div style='height:42px'><img src='/images/ajax-loader.gif'/></div>")
    return false;
  });
  $(".audio_more").live('click',function(){
    $(this).parent('.lang').children('.audio_hide').removeClass('audio_hide');
    $(this).parent('#movie-info').children('.audio_hide').removeClass('audio_hide');
    $(this).hide();
  });
  $(".subtitle_more").live('click',function(){
    $(this).parent('.lang').children('.subtitle_hide').removeClass('subtitle_hide');
    $(this).parent('#movie-info').children('.subtitle_hide').removeClass('subtitle_hide');
    $(this).hide();
  });
  
  var options = {dataType: 'script'};
  $('.new_wishlist_item .item, .new_wishlist_item .serie').live("click", function(){
    
    loader = 'ajax-loader.gif';
    /*$(this).parent().parent().parent().ajaxSubmit(options);*/
    if($(this).hasClass('serie'))
    {
      $(this).parents('.new_wishlist_item ').children('#all_movies').val(1)
    }
    product_id = $(this).parents('.new_wishlist_item').children('#wishlist_item_product_id').val()
    set_page($(this).parents('.new_wishlist_item').attr('action')+ "/products/" + product_id +"?recommendation="+$(this).parents('.new_wishlist_item').children('#wishlist_item_wishlist_source_id').val())
    radio_value = $(this).parent().parent().children('.col4').children('input:checked').val()
    $(this).parents('.new_wishlist_item').ajaxSubmit(options);
    $(this).parent().html("<div style='height:42px'><img src='/images/"+loader+"'/></div>");
    return false; // prevent default behaviour
  });
  var options = {dataType: 'script'};
  $('.remvove_from_wishlist').live("click", function(){
    
    url = $(this).parents('.remvove_from_wishlist_form').attr('action')
    value = $(this).val()
    
    loader = 'ajax-loader.gif';
    if ($(this).parent().parent().children('#load_color').attr('value') == 'black'){
      loader = 'black-'+loader;
    }
    $(this).parents('.remvove_from_wishlist_form').ajaxSubmit(options);
    
    $(this).parent().html("<div class='load'><img src='/images/"+loader+"' /></div>")
    return false; // prevent default behaviour
  });
  
  $('.streaming_add_list, .streaming_remove_list').live("click", function(){
    $(this).parent().ajaxSubmit(options);
    $(this).parent().html("<div class='load2'><img src='/images/ajax-loader.gif' /></div>")
    return false; // prevent default behaviour
  });
  
  
  $('#bluray_ok').live('click', function(){
    url = $(this).attr('href');
    $.getScript(url);
    $('#attention_bluray').hide();
    return false;
  });
  
  $("#sort").change(function() {
          $(this).parents().filter("form").trigger("submit");
  });
  $('#toTop').live('click', function(){
    goToByScroll('top')
  });
  if ($('#cl #pagination.active').length) {
      $(window).scroll(function() {
        var url;
        url = $('#cl #pagination .next_page').attr('href');
        if ($(window).scrollTop() < 500)
        {
          $('#toTop').fadeOut('slow')
        }
        else
        {
          $('#toTop').fadeIn('slow')
        }
        if (url && $(window).scrollTop() > $(document).height() - $(window).height() - 1200) {
          set_page(url)
          $('#pagination').html("<img src='/images/loading.gif' />");
          return $.getScript(url);
        }
      });
      return $(window).scroll();
  }
});
function submit_online()
{
  if($('#cl').length > 0){
    $('.loading_bar').show();
    /*$('#filter_online_form').ajaxSubmit({dataType: 'script'});*/
    if($('#filter_online_form').attr('action').indexOf('?')>0)
    {
      history_url = $('#filter_online_form').attr('action')+"&"+$('#filter_online_form').serialize()  
    }
    else
    {
      history_url = $('#filter_online_form').attr('action')+"?"+$('#filter_online_form').serialize()
    }
    console.log('push')
    History.pushState(null, null, history_url);
  }
  else
  {
    $('#filter_online_form').submit();
  }
}

History.Adapter.bind(window,'statechange',function(){ // Note: We are using statechange instead of popstate
    // Log the State
    console.log('here')
    var State = History.getState(); // Note: We are using History.getState() instead of event.state
    $('.loading_bar').show()
    $.ajax({
      url: State.url,
      dataType: 'script',
      type: 'GET',
      data: {},
      success: function(data) {},
      error: function() {}
    });
  })
function load_form()
{
  $('.chosen-select').chosen({allow_single_deselect: true}).change(function(){submit_online()});
  $("#online #ratings-slider-range").slider({
    range: true,
    min: 1,
    max: 5,
    values: [$("#filters_rating_min").val(),$("#filters_rating_max").val()],
    step: 1,
    change: function(event, ui) {
      $("#online #filters_rating_min").val(ui.values[0]);
      $("#online #filters_rating_max").val(ui.values[1]);
       submit_online()
    }
  });
  audience_slider_values = {'0': 0, '10': 1, '12': 2, '16': 3, '18': 4};
  $("#online #audience-slider-range").slider({
    range: true,
    min: 0,
    max: 4,
    values: [audience_slider_values[$("#online #filters_audience_min").val()], audience_slider_values[$("#online #filters_audience_max").val()]],
    step: 1,
    change: function(event, ui) {
      actual_audience_values = {'0': 0, '1': 10, '2': 12, '3': 16, '4': 18};
      $("#online #filters_audience_min").val(actual_audience_values[ui.values[0]]);
      $("#online #filters_audience_max").val(actual_audience_values[ui.values[1]]);
      submit_online()
    }
  });
}  
function goToByScroll(id){
  $('html,body').animate({scrollTop: $("#"+id).offset().top},'slow');
}