$(function() {
  $('#user-movies li').live('mouseover',function(){
    $(this).children('.overlay').show()
  });
  $('#user-movies li').live('mouseout',function(){
    $(this).children('.overlay').hide()
  });
  
  $("#user-movies-wrap .close").live("click", function() {
    url = $(this).attr('href');
    html_item = $(this);
    content = html_item.html();
    loader = 'ajax-loader.gif';
    html_item.html("<img src='/images/"+loader+"'/>");
    $.ajax({
      url: url,
      type: 'GET',
      data: {},
      success: function(data) {
        html_item.parent().parent().replaceWith(data);  
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });
  $('#news-wrap .pagination a, #news-wrap .pagination2 a').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#news-wrap');
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
  $('#selection-tabcontent-wrap .content-tabs a').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#selection-week-wrap');
    html_content = $('#selection-tabcontent-wrap .carousel-wrap');
    content = html_content.html()
    $('#selection-tabcontent-wrap .content-tabs a').removeClass('active') 
    $(this).addClass('active')
    html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
    $.ajax({
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.html(data);
      },
      error: function() {
        html_content.html(content);
      }
    });
    return false;
  });
  $('#selection-tabcontent-wrap .pagination a,#selection-tabcontent-wrap .pagination2 a').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#selection-week-wrap');
    html_content = $('#selection-tabcontent-wrap .slides');
    content = html_content.html()
    html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
    $.ajax({
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.html(data);
      },
      error: function() {
        html_content.html(content);
      }
    });
    return false;
  });
  
  $('#tab1, #tab2, #tab3, #tab4').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#review_content');
    html_content = $('.tab-content');
    content = html_content.html()
    $('#tabs-review li a.active').removeClass('pie') 
    $('#tabs-review li a.active').removeClass('active')
    $(this).addClass('active pie')
    html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
    $.ajax({
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.html(data);
      },
      error: function() {
        html_content.html(content);
      }
    });
    return false;
  });

  $('.tab-content a.next_page').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#review_content');
    html_content = $('.content_item');
    content = html_content.html()
    link = $(this);
    link_content = link.html()
    $(this).html("<div style='height:24px; margin:9px 0 0 0'><img src='/images/ajax-loader.gif'/></div>");
    $.ajax({
      url: url,
      type: 'GET',
      success: function(data) {
        /*content += data
        html_content.html(content);*/
      },
      error: function() {
        /*link.html(link_content);*/
      }
    });
    return false;
  });
  
  //carousel
  var current;
  setCurrent(5);
  $container = $('.slider_normal').cycle({ 
      fx: 'turnLeft', 
      timeout: 17000,
      before: change_carousel
  });
  $container_x = $('.slider_adult').cycle({ 
      fx: 'turnLeft', 
      timeout: 5000,
      before: change_carousel_adult,
      next:   '#next', 
      prev:   '#back',
  });
  
  function getCurrent()
  {
    return current;
  }
  function setCurrent(_current)
  {
    current = _current;
  }
  $('.slider-wrap_adult .pagination a').click(function() { 
      id = $(this).attr('id');
      id = parseInt(id.replace("btn_",""),10);
      $container_x.cycle(id-1); 
      return false; 
  });
  $('.slider-wrap_normal .pagination a').click(function() { 
      id = $(this).attr('id');
      id = parseInt(id.replace("btn_",""),10);
      $container.cycle(id-1); 
      return false; 
  });
  function set_page(url)
  {
    url = url.replace('http://dvdpost.dev','')
    url = url.replace('http://staging.dvdpost.be','')
    url = url.replace('http://beta.dvdpost.com','')
    url = url.replace('http://private.dvdpost.com','')
    url = url.replace('http://public.dvdpost.com','')
    alert(url)
    _gaq.push(['_trackPageview', url]); 
  }
  

  function change_carousel_adult()
  {
    image = $(this).attr('id')
    reg= new RegExp(/[^\d]/g)
    id = parseInt(image.replace(reg,''),10)+1
    setCurrent(id)
    $('.pagination a.active').removeClass('active');
    $('#btn_'+id).addClass('active');
  }
  function change_carousel()
  {
    image = $(this).attr('id')
    reg= new RegExp(/[^\d]/g)
    id = parseInt(image.replace(reg,''),10)+1
    setCurrent(id)
    $('.pagination a.active').removeClass('active');
    $('#btn_'+id).addClass('active');
    
  }

  $('.top_actors').live('mouseover',function(){
    var reg = new RegExp('[actor_id]', 'gi');
    id =$(this).attr('id').replace(reg,'');
    var reg_jpg = new RegExp(/\/[\d]*_[\d]\.jpg/);
    src = $('#top_actor').attr('src')
    new_src = src.replace(reg_jpg, "/"+id+"_1.jpg");
    $('#top_actor').attr('src',new_src)
    new_href =$(this).attr('href')
    $('#top_actor_link').attr('href',new_href)
    
  });

  $('.top_products').live('mouseover',function(){
    image =$(this).attr('id');
    id = $(this).parent('li').attr('id')
    var reg_jpg = new RegExp(/dvd\/.*/);
    var reg_link = new RegExp(/\/[\d]+/);
    src = $('#top_product').attr('src')
    new_src = src.replace(reg_jpg, image);
    $('#top_product').attr('src',new_src)
    actor_href = $('#top_product_link').attr('href')
    new_href =actor_href.replace(reg_link, "/"+id);
    $('#top_product_link').attr('href',new_href)
  });
  if ($('#popup').html()!=undefined)
  {
    jQuery.facebox(function() {
      $.getScript($('#popup').html(), function(data) {
        jQuery.facebox(data);
      });
    });
  }
  $(".review_more").live("click", function() {
    wishlist_item = $(this);
    jQuery.facebox(function() {
      $.getScript(wishlist_item.attr('href'), function(data) {
        jQuery.facebox(data);
      });
    });
    return false;
  });
  
  $(".tooltips").live('mouseover',function(){
    name =$(this).attr('id')+"_popup"
    var bulle = $("#"+name);
    bulle.show()
    return false;
  });
  $(".tooltips").live('mouseout',function(){
    name =$(this).attr('id')+"_popup"
    var bulle = $("#"+name);
    bulle.hide();
    return false;
  });
  $(".tooltips").live('click',function(){
    return false;
  });

});
