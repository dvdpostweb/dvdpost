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
  $('#home_popular #carousel-wrap-hp a.next_page').live('click',function(){
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
  
  function getCurrent()
  {
    return current;
  }
  function setCurrent(_current)
  {
    current = _current;
  }
  $('.menu_carousel').click(function() { 
      id = $(this).attr('id');
      id = parseInt(id.replace("carousel_",""),10);
      setCurrent(id-1)
      $container.cycle(id-1); 
      return false; 
  });
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
    var reg_jpg = new RegExp(/\/[\d]*\.jpg/);
    var reg_link = new RegExp(/\/[\d]*\//);
    src = $('#top_actor').attr('src')
    new_src = src.replace(reg_jpg, "/"+id+".jpg");
    $('#top_actor').attr('src',new_src)
    actor_href = $('#top_actor_link').attr('href')
    new_href =actor_href.replace(reg_link, "/"+id+"/");
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
});
