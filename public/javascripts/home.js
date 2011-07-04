$(function() {
  $('#news a.next_page').live('click',function(){
    url = this.href;
    html_item = $('#news');
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
  
  $('#home_recommendations #carousel-wrap-hp a.next_page').live('click',function(){
    url = this.href;
    html_item_recommendation = $('#home_recommendations');
    content = html_item_recommendation.html()
    $.ajax({
      url: url,
      type: 'GET',
      success: function(data) {
        html_item_recommendation.replaceWith(data);
      },
      error: function() {
        html_item_recommendation.replaceWith(content);
      }
    });
    return false;
  });
  
  $('#home_recommendations #carousel-wrap-hp a.prev_page').live('click',function(){
    url = this.href;
    html_item_recommendation = $('#home_recommendations');
    content = html_item_recommendation.html()
    $.ajax({
      url: url,
      type: 'GET',
      success: function(data) {
        html_item_recommendation.replaceWith(data);
      },
      error: function() {
        html_item_recommendation.replaceWith(content);
      }
    });
    return false;
  });
  
  $('#tab1, #tab2, #tab3, #tab4').live('click',function(){
    url = this.href;
    html_item = $('#review_content');
    html_content = $('.tab-content');
    content = html_content.html()
    html_content.html("<div style='height:42px'><img src='/images/ajax-loader.gif'/></div>");
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
    html_item = $('#review_content');
    html_content = $('.content_item');
    content = html_content.html()
    link = $(this);
    link_content = link.html()
    $(this).html("<div style='height:33px'><img src='/images/ajax-loader.gif'/></div>");
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
  
  $('#home_popular #carousel-wrap-hp a.prev_page').live('click',function(){
    url = this.href;
    html_item = $('#home_popular');
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
  $('#home_popular #carousel-wrap-hp a.prev_page').live('click',function(){
    url = this.href;
    html_item = $('#home_popular');
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
  //carousel
  var current;
  setCurrent(5);
  $container = $('.panels').cycle({ 
      fx: 'turnLeft', 
      timeout: 15000,
      before: change_carousel
  });
  $container_x = $('.panels_adult').cycle({ 
      fx: 'turnLeft', 
      timeout: 30000,
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
  $('#slider-nav a').click(function() { 
      id = $(this).attr('id');
      id = parseInt(id.replace("btn_",""),10);
      $container_x.cycle(id-1); 
      return false; 
  });
  $('.menu_carousel').click(function() { 
      id = $(this).attr('id');
      id = parseInt(id.replace("carousel_",""),10);
      setCurrent(id-1)
      $container.cycle(id-1); 
      return false; 
  });
  
  

  function change_carousel_adult()
  {
    image = $(this).attr('id')
    reg= new RegExp(/[^\d]/g)
    id = parseInt(image.replace(reg,''),10)+1
    setCurrent(id)
    $('#slider-nav a.active').removeClass('active');
    $('#btn_'+id).addClass('active');
    $('#carousel_title').html($('#title_'+id).html())
    $('#carousel_link').html($('#name_'+id).html())
    $('#carousel_link').attr('href',$('#link_'+id).html())
  }
  function change_carousel()
  {
    setCurrent(getCurrent() + 1);
    if(getCurrent() == 6) setCurrent( 1);
    $('#tabs-rotator #tabs a.active').removeClass('active');
    $('#carousel_'+getCurrent()).addClass('active');
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
    var reg_jpg = new RegExp(/dvd\/[\w]*\.jpg/);
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
});
