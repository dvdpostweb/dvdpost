$(function() {
  // Ajax history, only works on the product.reviews for now
  var options_review = {
    success: show_review
  }  
  if(($('#image_5').attr('src')!=undefined))
  {
  var img = new Image();
  img.onload = function() {
     height_im = this.height
     if(height_im > 3)
     {
       $('#trailer_mask').show()
     }
     else
     {
       $('#thumbs-wrap').hide()
     }
     
  }
  img.src = $('#image_5').attr('src');
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
  $(document).bind("fragmentChange.reviews_page", function() {
    $.getScript($.queryString(document.location.href, { 'reviews_page': $.fragment().reviews_page }));
  });
  if ($.fragment().reviews_page) {
    $(document).trigger("fragmentChange.reviews_page");
  }

  $("#tab-content-movie #pagination a, #trailer_pagination a").live("click", function() {
    html_item = $(this);
    content = html_item.html();
    html_item.html("Loading...");
    root_item = html_item.parent().parent().parent();
    $.ajax({
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
    $.ajax({
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
    jQuery.facebox(function() {
      $.getScript(wishlist_item.attr('href'), function(data) {
        jQuery.facebox(data);
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
    $.ajax({
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
    $.ajax({
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
    $.ajax({
      url: this.href,
      dataType: 'script',
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

  audience_slider_values = {'0': 0, '10': 1, '12': 2, '16': 3, '18': 4};
  $("#audience-slider-range").slider({
    range: true,
    min: 0,
    max: 4,
    values: [audience_slider_values[$("#search_filter_audience_min").val()], audience_slider_values[$("#search_filter_audience_max").val()]],
    step: 1,
    slide: function(event, ui) {
      actual_audience_values = {'0': 0, '1': 10, '2': 12, '3': 16, '4': 18};
      $("#search_filter_audience_min").val(actual_audience_values[ui.values[0]]);
      $("#search_filter_audience_max").val(actual_audience_values[ui.values[1]]);
    }
  });

  year_slider_values = {'0': 0, '1940': 1, '1950': 2, '1960': 3, '1970': 4, '1980': 5, '1990': 6, '2000': 7, '2020': 8};
  $("#year-slider-range").slider({
    range: true,
    min: 0,
    max: 8,
    values: [year_slider_values[$("#search_filter_year_min").val()], year_slider_values[$("#search_filter_year_max").val()]],
    step: 1,
    slide: function(event, ui) {
      actual_year_values = {'0': 0, '1': 1940, '2': 1950, '3': 1960, '4': 1970, '5': 1980, '6': 1990, '7': 2000, '8': 2020};
      $("#search_filter_year_min").val(actual_year_values[ui.values[0]]);
      $("#search_filter_year_max").val(actual_year_values[ui.values[1]]);
    }
  });

  $("#ratings-slider-range").slider({
    range: true,
    min: 0,
    max: 5,
    values: [$("#search_filter_rating_min").val(),$("#search_filter_rating_max").val()],
    step: 1,
    slide: function(event, ui) {
      $("#search_filter_rating_min").val(ui.values[0]);
      $("#search_filter_rating_max").val(ui.values[1]);
    }
  });

  $('#carousel-wrap #next,#carousel-wrap .next_page').live('click',function(){
    url = this.href;
    html_item = $('#carousel-wrap');
    content = html_item.html();
    $.ajax({
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
    $.ajax({
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
    $.ajax({
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
    $.ajax({
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

  $('#all_categorie').live('click',function(){
    $('.cat').show();
    $('.subcat').hide();
    $(this).hide();
    return false;
  });

  $('.trailer').live('click', function(){
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.getScript(url, function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });
  $('#codePromo').live('click', function(){
    url = $(this).attr('href');
    jQuery.facebox(function() {
      $.getScript(url, function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });
  var options = {};
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
    $("#new_review").ajaxSubmit(options);
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
  
  var options = {};
  $('#wishlist_item_submit.item').live("click", function(){
    loader = 'ajax-loader.gif';
    $('#add_to_wishlist').html("<div style='height:42px'><img src='/images/"+loader+"'/></div>")
    $('form.#new_wishlist_item').ajaxSubmit(options);
    return false; // prevent default behaviour
  });
  var options = {};
  $('.remvove_from_wishlist').live("click", function(){
    loader = 'ajax-loader.gif';
    if ($(this).parent().parent().children('#load_color').attr('value') == 'black'){
      loader = 'black-'+loader;
    }
    $(this).parent().parent().ajaxSubmit(options);
    
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
  if ($('#add_p, #review, #rating').html()!=undefined)
  {
    jQuery.facebox(function() {
      $.getScript($('#add').html(), function(data) {
        jQuery.facebox(data);
      });
    });
  }
  
});
