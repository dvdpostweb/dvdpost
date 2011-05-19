$(function() {
  // Ajax history, only works on the product.reviews for now
  $('.actors').live('mouseover',function(){
    reg= new RegExp(/[^\d]/g)
    reg_a= new RegExp(/[^\a-z]/g)
    
    link = $(this).attr('id');
    id = parseInt(link.replace(reg,''),10)
    letter = link.replace(reg_a,'')
    var reg_jpg = new RegExp(/\/[\d]*_[\d]\.jpg/);
    var reg_link = new RegExp(/\/[\d]*\//);
    image_id = "#thumb_"+letter
    src = $(image_id).attr('src')
    new_src = src.replace(reg_jpg, "/"+id+"_1.jpg");
    $(image_id).attr('src',new_src)
    actor_href = $("#thumb_link_"+letter).attr('href')
    new_href =actor_href.replace(reg_link, "/"+id+"/");
    $("#thumb_link_"+letter).attr('href',new_href)
    
  });
});
