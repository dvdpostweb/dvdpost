$(function() {
  // Ajax history, only works on the product.reviews for now
  $("#tab1 #pagination a").live("click", function() {
    $.setFragment({ reviews_page: $.queryString(this.href).reviews_page })
  });
  $(document).bind("fragmentChange.reviews_page", function() {
    $.getScript($.queryString(document.location.href, { 'reviews_page': $.fragment().reviews_page }));
  });
  if ($.fragment().reviews_page) {
    $(document).trigger("fragmentChange.reviews_page");
  }

  $("#tab1 #pagination a").live("click", function() {
    html_item = $(this);
    content = html_item.html();
    html_item.html("Loading...");
    root_item = html_item.parent().parent();
    $.ajax({
      url: html_item.attr('href'),
      type: 'GET',
      success: function(data) {
        root_item.html(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });

  $(".stars .star, #cotez .star").live("click", function() {
    url = $(this).parent().attr('href');
    html_item = $(this).parent().parent();
    content = html_item.html();
    loader = 'ajax-loader.gif';
    if ($(this).attr('src').match(/black-star-/i)){
      loader = 'black-'+loader;
    }
    html_item.html("<img src='/images/"+loader+"'/>");
    $.ajax({
      url: url,
      type: 'POST',
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
    for(var i=1; i<=5; i++)
    {
      if(i <= rating_value){
        full_image = image+'on';
      }else{
        full_image = image+'off';
      }
      $('#star_'+product_id+"_"+i).attr('src', '/images/'+full_image+'.jpg');
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

  $(".add_to_wishlist_button").live("click", function() {
    wishlist_item = $(this);
    jQuery.facebox(function() {
      $.getScript(wishlist_item.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });

  $(".action .links a").live("click", function() {
    html_item = $(this).parent();
    content = html_item.html();
    html_item.html("Saving...");
    $.ajax({
      url: this.href,
      type: 'POST',
      success: function(data) {
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

  $("#close-f a").click(function() {
    $("#filtered").hide();
    return false;
  });

  if($("#leftcolumn #filters").length > 0) {
    if($.query.get('media') == ''){
      $("#filters li.technology").toggleClass('open');
      $("#filters li.technology").find("div").toggle(1);
    }
    if($.query.get('public_max') == '' || ($.query.get('public_min') == 0 && $.query.get('public_max') == 18)){
      $("#filters li.public").toggleClass('open');
      $("#filters li.public").find("div").toggle(1);
    }
    if($.query.get('country') == '' || $.query.get('country') == 0){
      $("#filters li.country").toggleClass('open');
      $("#filters li.country").find("div").toggle(1);
    }
    if($.query.get('year_max') == '' || ($.query.get('year_min') == 0 && $.query.get('year_max') == 2010)){
      $("#filters li.year").toggleClass('open');
      $("#filters li.year").find("div").toggle(1);
    }
    if($.query.get('ratings_max') == '' || ($.query.get('ratings_min') == 0 && $.query.get('ratings_max') == 5)){
      $("#filters li.ratings").toggleClass('open');
      $("#filters li.ratings").find("div").toggle(1);
    }
    if($.query.get('languages') == ''){
      $("#filters li.audio").toggleClass('open');
      $("#filters li.audio").find("div").toggle(1);
    }
    if($.query.get('subtitles') == ''){
      $("#filters li.subtitles").toggleClass('open');
      $("#filters li.subtitles").find("div").toggle(1);
    }
    if($.query.get('dvdpost_choice') == ''){
      $("#filters li.dvdpost_choice").toggleClass('open');
      $("#filters li.dvdpost_choice").find("div").toggle(1);
    }
  }
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
    $('#tab1').toggle();
    $('#tab2').toggle();
    $('#tab1_li').toggleClass('active');
    $('#tab2_li').toggleClass('active');
    return false;
  });

  public_slider_values = {'0': 0, '10': 1, '12': 2, '16': 3, '18': 4};
  $("#public-slider-range").slider({
    range: true,
    min: 0,
    max: 4,
    values: [public_slider_values[$("#public_min").val()], public_slider_values[$("#public_max").val()]],
    step: 1,
    slide: function(event, ui) {
      actual_public_values = {'0': 0, '1': 10, '2': 12, '3': 16, '4': 18};
      $("#public_min").val(actual_public_values[ui.values[0]]);
      $("#public_max").val(actual_public_values[ui.values[1]]);
    }
  });

  year_slider_values = {'0': 0, '1940': 1, '1950': 2, '1960': 3, '1970': 4, '1980': 5, '1990': 6, '2000': 7, '2010': 8};
  $("#year-slider-range").slider({
    range: true,
    min: 0,
    max: 8,
    values: [year_slider_values[$("#year_min").val()], year_slider_values[$("#year_max").val()]],
    step: 1,
    slide: function(event, ui) {
      actual_year_values = {'0': 0, '1': 1940, '2': 1950, '3': 1960, '4': 1970, '5': 1980, '6': 1990, '7': 2000, '8': 2010};
      $("#year_min").val(actual_year_values[ui.values[0]]);
      $("#year_max").val(actual_year_values[ui.values[1]]);
    }
  });

  $("#ratings-slider-range").slider({
    range: true,
    min: 0,
    max: 5,
    values: [$("#ratings_min").val(),$("#ratings_max").val()],
    step: 1,
    slide: function(event, ui) {
      $("#ratings_min").val(ui.values[0]);
      $("#ratings_max").val(ui.values[1]);
    }
  });

  $('#carousel #next').live('click',function(){
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
  
  $('#carousel #prev').live('click',function(){
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
  search_text=$('#s').attr('value')
  $('#s').live('focus',function(){
    if($('#s').attr('value') == search_text)
    {
      $('#s').val('');
    }
  });
  $('#s').live('blur',function(){
    if($('#s').attr('value') == '')
    {
      $('#s').val(search_text);
    }
  });

  $('#carousel-wrap a.next_page').live('click',function(){
    url = this.href;
    html_item = $('#carousel-wrap');
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
  
  $('#carousel-wrap a.prev_page').live('click',function(){
    url = this.href;
    html_item = $('#home_recommendations');
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
});
