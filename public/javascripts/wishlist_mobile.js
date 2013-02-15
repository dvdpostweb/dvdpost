$(function() {
  var options_change_priority = {
    dataType: 'script'
	};
  $(".wishlist_item_priority").live("click", function() {
    url = $(this).parent().parent().attr('action')
    value = $(this).val()
    var regex = new RegExp(".*/wishlist_items/([0-9]*).*");
    res = regex.exec(url)
    
    loader = 'ajax-loader.gif';
    $(this).parent().parent().ajaxSubmit(options_change_priority);
    html_item = $(this).parent().parent()
    parent = $(this).parent().parent()
    content = html_item.html();
    $(this).parent().parent().html("<div style='height:17px; text-align:center' class='load'><img src='/images/"+loader+"'/></div>")
    return false; // prevent default behaviour
  });
  
});
