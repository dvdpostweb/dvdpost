$(document).ready(function() {
  setCurrent(5);
  $container_x = $('.slider_adult').cycle({ 
      fx: 'scrollHorz', 
      timeout: 5000,
      before: change_carousel_adult,
      next:   '#next', 
      prev:   '#back',
  });
  function change_carousel_adult()
  {
    image = $(this).attr('id')
    reg= new RegExp(/[^\d]/g)
    id = parseInt(image.replace(reg,''),10)+1
    setCurrent(id)
    $('.pagination a.active').removeClass('active');
    $('#btn_'+id).addClass('active');
  }
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

  $('#selection-week-wrap .pagination a, #selection-week-wrap .pagination2 a').live('click',function(){
    url = this.href;
    set_page(url)
    html_item = $('#selection-week-wrap');
    html_content = $('#weekly-selection-wrap .carousel-wrap');
    content = html_content.html()
    html_content.html("<div style='height:42px;'><img src='/images/ajax-loader.gif'/></div>");
    $.ajax({dataType: 'html',
      url: url,
      type: 'GET',
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_content.html(content);
      }
    });
    return false;
  });
});