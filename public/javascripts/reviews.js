$(function() {
  $("a#add_new_review, .add_reviews").live("click", function() {
    review = $(this);
    url = review.attr('href')
    set_page(review.attr('href'))
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
  $("#new_review .star").live("mouseover", function(){
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
      $('#new_review #star_'+product_id+"_"+i).attr('src', '/images/'+full_image+'.png');
    }
  });
  $("#new_review .star").live("mouseout", function() {
    product_id = $(this).attr('id').replace('star_','').split('_')[0];
    for(var i=1; i<=5; i++)
    {
      image = $('#new_review #star_'+product_id+'_'+i);
      image.attr('src','/images/'+image.attr('name'));
    }
  });
  $("#new_review .star").live("click", function(){
    url = $(this).parent().attr('href');
    var value = querySt(url,'value');
    $('#review_rating').val(value);
    image = 'star-voted-';    
    for(var i=1; i<=5; i++)
    {
      if(i <= value){
        full_image = image+'on';
      }else{
        full_image = image+'off';
      }
      $('#new_review #star_'+product_id+"_"+i).attr('name', full_image+'.png');
      
    }
    return false;
  });
  $(".yn .yes, .yn .no").live("click",function(){
    $(this).parent("p.yn").html('<img src="/images/ajax-loader.gif" />');
    review_id = $(this).attr('review_id');
    html_item = $('#critique'+review_id);
    content = html_item.html();
    set_page($(this).attr('href'))
    $.ajax({dataType: 'html',
      url: $(this).attr('href'),
      type: 'POST',
      data: {},
      success: function(data) {
        html_item.replaceWith(data);
      },
      error: function() {
        html_item.html(content);
      }
    });
    return false;
  });
});

function querySt(hu ,ji) {
  gy = hu.split("&");
  for (i=0;i<gy.length;i++) {
    ft = gy[i].split("=");
    if (ft[0] == ji) {
      return ft[1];
    }
  }
}
