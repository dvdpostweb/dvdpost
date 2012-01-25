
$(function() {
  // Ajax history, only works on the product.reviews for now
  $('.shop_action').live('click',function(){
    loader = 'ajax-loader.gif';
    
    $(this).parent().parent().ajaxSubmit();
    $(this).parent().html("<div style='height:31px'><img src='/images/"+loader+"'/></div>")
    return false;
  });
});
