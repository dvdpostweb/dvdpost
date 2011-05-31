$(function() {
  // Ajax history, only works on the product.reviews for now
  $('.actors').live('mouseover',function(){
    reg = new RegExp(/[^\d]/g)
    reg_a = new RegExp(/[^\a-z]/g)
    link = $(this).attr('id');
    id = parseInt(link.replace(reg,''),10)
    letter = link.replace(reg_a,'')
    var reg_jpg = new RegExp(/\/[\d]*_[\d]\.jpg/);
    image_id = "#thumb_"+letter
    src = $(image_id).attr('src')
    new_src = src.replace(reg_jpg, "/"+id+"_1.jpg");
    $(image_id).attr('src',new_src)
    
    new_href =$(this).attr('href');
    if ($('#search-performers').hasClass('letter'))
    {
      if ($(this).hasClass('picture')){
        var position_top = $(this).offset().top;
        var position_left = $(this).offset().left;
       
        init_left = $("#wrap").offset().left
        $(".thumb").css({top: position_top-180,left: (position_left - init_left-200)});
        $(image_id).attr('src',new_src)
        $("#thumb_link_"+letter).attr('href',new_href)
        $(".thumb").show()
      }
      else
      {
         $(".thumb").hide()
      }
    }
    else
    {
       $(image_id).attr('src',new_src)
       $("#thumb_link_"+letter).attr('href',new_href)
    }
    
    active = '#'+letter+' .active'
    $(active).removeClass('active')
    $(this).addClass('active')
    
  });
});
