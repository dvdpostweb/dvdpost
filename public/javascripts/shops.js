
$(function() {
  // Ajax history, only works on the product.reviews for now
  $('.shop_action').live('click',function(){
    $(this).parent().parent().ajaxSubmit({dataType: 'script'});
    $(this).parent().html("<div style='height:31px'><img src='/images/ajax-loader.gif' /></div>")
    return false;
  });
  $('#shopping_cart_quantity').live('change', function(){
    $(this).parent().parent().submit();
    $(this).parent().html("<div style='height:31px'><img src='/images/ajax-loader.gif' /></div>")
  });
});
